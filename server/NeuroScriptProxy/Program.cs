using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;
using System.Text;
using NeuroScriptProxy.Models;
using NeuroScriptProxy.Services;

var builder = WebApplication.CreateBuilder(args);

// Enforce request body size limits at the Kestrel web server level (256 KB max)
builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.Limits.MaxRequestBodySize = 256 * 1024; // 256 KB
});

// Configure CORS with explicitly configured origins (never AllowAnyOrigin)
var allowedOrigins = builder.Configuration.GetSection("AllowedOrigins").Get<string[]>()
    ?? new[] { "https://neuroscript.uet.edu.pk", "http://localhost:3000" };

builder.Services.AddCors(options =>
{
    options.AddPolicy("ConfiguredOrigins", p =>
    {
        p.WithOrigins(allowedOrigins)
         .AllowAnyMethod()
         .AllowAnyHeader()
         .WithExposedHeaders("X-RateLimit-Limit", "X-RateLimit-Remaining", "Retry-After");
    });
});

// Fail startup in production if required API keys are missing
var geminiApiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY");
var proxyApiKey = builder.Configuration["NEUROSCRIPT_PROXY_API_KEY"] ?? Environment.GetEnvironmentVariable("NEUROSCRIPT_PROXY_API_KEY");

if (builder.Environment.IsProduction())
{
    if (string.IsNullOrWhiteSpace(geminiApiKey))
    {
        throw new InvalidOperationException("Fatal startup failure: GEMINI_API_KEY environment variable is missing in production.");
    }
    if (string.IsNullOrWhiteSpace(proxyApiKey))
    {
        throw new InvalidOperationException("Fatal startup failure: NEUROSCRIPT_PROXY_API_KEY configuration or environment variable is missing in production.");
    }
}

// Register dependencies
builder.Services.AddHttpClient();
builder.Services.AddSingleton<RateLimiter>();

if (!string.IsNullOrWhiteSpace(geminiApiKey))
{
    builder.Services.AddSingleton<ILessonGenerator, GeminiLessonGenerator>();
}
else
{
    builder.Services.AddSingleton<ILessonGenerator, MockLessonGenerator>();
}

var app = builder.Build();

// Add HTTPS redirection + HSTS in production
if (app.Environment.IsProduction())
{
    app.UseHsts();
    app.UseHttpsRedirection();
}

app.UseCors("ConfiguredOrigins");

// 1. Health check endpoint (GET /health)
app.MapGet("/health", (ILessonGenerator generator) =>
{
    return Results.Ok(new HealthResponse(
        Status: "Healthy",
        Timestamp: DateTime.UtcNow,
        Provider: generator.ProviderName
    ));
});

// 2. Lesson generation endpoint (POST /api/v1/lessons/generate)
app.MapPost("/api/v1/lessons/generate", async (
    [FromHeader(Name = "X-Api-Key")] string? apiKey,
    [FromHeader(Name = "X-Install-Id")] string? installId,
    IConfiguration configuration,
    [FromBody] GenerateLessonRequest request,
    RateLimiter rateLimiter,
    ILessonGenerator generator,
    ILogger<Program> logger,
    HttpContext httpContext) =>
{
    var sw = System.Diagnostics.Stopwatch.StartNew();

    // A client key must be provisioned on the server; never accept any non-empty value.
    var configuredApiKey = configuration["NEUROSCRIPT_PROXY_API_KEY"] ?? Environment.GetEnvironmentVariable("NEUROSCRIPT_PROXY_API_KEY");
    if (string.IsNullOrWhiteSpace(configuredApiKey))
    {
        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/proxy-not-configured",
            Title: "Proxy Not Configured",
            Status: 503,
            Detail: "The proxy API key has not been configured on this server.",
            ErrorCode: "PROXY_NOT_CONFIGURED"
        ), statusCode: 503, contentType: "application/problem+json");
    }

    var suppliedKey = Encoding.UTF8.GetBytes(apiKey ?? string.Empty);
    var expectedKey = Encoding.UTF8.GetBytes(configuredApiKey);
    if (!CryptographicOperations.FixedTimeEquals(suppliedKey, expectedKey))
    {
        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/unauthorized",
            Title: "Unauthorized",
            Status: 401,
            Detail: "The supplied proxy API key is invalid.",
            ErrorCode: "UNAUTHORIZED"
        ), statusCode: 401, contentType: "application/problem+json");
    }

    var effectiveInstallId = string.IsNullOrWhiteSpace(installId)
        ? "anonymous-client"
        : installId.Trim();

    // Check sliding-window rate limit
    var (isAllowed, remaining, retryAfter) = rateLimiter.CheckLimit(effectiveInstallId);
    httpContext.Response.Headers["X-RateLimit-Limit"] = rateLimiter.Limit.ToString();
    httpContext.Response.Headers["X-RateLimit-Remaining"] = remaining.ToString();

    if (!isAllowed)
    {
        httpContext.Response.Headers["Retry-After"] = retryAfter.ToString();
        var maskedId = effectiveInstallId.Length > 8
            ? $"{effectiveInstallId[..4]}...{effectiveInstallId[^4..]}"
            : "****";
        logger.LogWarning("[AUDIT] Rate limit exceeded for InstallId: {InstallId}", maskedId);

        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/rate-limited",
            Title: "Rate Limit Exceeded",
            Status: 429,
            Detail: $"Rate limit of {rateLimiter.Limit} requests per minute exceeded. Please retry after {retryAfter} seconds.",
            ErrorCode: "RATE_LIMITED"
        ), statusCode: 429, contentType: "application/problem+json");
    }

    // Validate input body presence and basic structure
    if (request == null || string.IsNullOrWhiteSpace(request.NoteHash) || request.Lines == null || request.Lines.Count == 0)
    {
        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/invalid-input",
            Title: "Invalid Request Payload",
            Status: 400,
            Detail: "Payload must contain noteHash and non-empty lines array.",
            ErrorCode: "INVALID_INPUT"
        ), statusCode: 400, contentType: "application/problem+json");
    }

    // Enforce line count constraint (max 200 lines per submission)
    if (request.Lines.Count > 200)
    {
        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/payload-too-large",
            Title: "Too Many Lines",
            Status: 413,
            Detail: $"Submitted note contains {request.Lines.Count} lines, which exceeds the maximum limit of 200 lines per lesson request.",
            ErrorCode: "LINE_LIMIT_EXCEEDED"
        ), statusCode: 413, contentType: "application/problem+json");
    }

    // Enforce character count constraint (max 25,000 characters per submission)
    var totalChars = request.Lines.Sum(l => l?.Length ?? 0);
    if (totalChars > 25000)
    {
        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/payload-too-large",
            Title: "Content Exceeds Character Limit",
            Status: 413,
            Detail: $"Submitted note contains {totalChars} characters, which exceeds the maximum limit of 25,000 characters per lesson request.",
            ErrorCode: "CHAR_LIMIT_EXCEEDED"
        ), statusCode: 413, contentType: "application/problem+json");
    }

    try
    {
        var lesson = await generator.GenerateLessonAsync(request);
        sw.Stop();

        // Privacy-first audit logging: metadata only, never raw notes, titles, or card contents.
        // Identifiers are masked to prevent personal re-identification.
        var maskedInstallId = effectiveInstallId.Length > 8
            ? $"{effectiveInstallId[..4]}...{effectiveInstallId[^4..]}"
            : "****";

        logger.LogInformation(
            "[AUDIT] Method=POST Endpoint=/api/v1/lessons/generate ClientId={ClientId} Profile={Profile} Lines={LineCount} Chars={CharCount} Status=200 Latency={ElapsedMs}ms",
            maskedInstallId, request.Profile, request.Lines.Count, totalChars, sw.ElapsedMilliseconds);

        return Results.Ok(lesson);
    }
    catch (Exception ex)
    {
        sw.Stop();
        logger.LogError(ex, "Internal error generating study lesson for Profile: {Profile}", request.Profile);

        // Sanitize error detail: never leak raw stack traces or internal exception messages
        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/upstream-error",
            Title: "Generation Failed",
            Status: 502,
            Detail: "An internal error occurred while generating the study lesson. Please try again later.",
            ErrorCode: "UPSTREAM_ERROR"
        ), statusCode: 502, contentType: "application/problem+json");
    }
});

app.Run();

// Expose Program class for WebApplicationFactory in integration tests
public partial class Program { }
