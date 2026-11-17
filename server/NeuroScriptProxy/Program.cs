using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;
using System.Text;
using NeuroScriptProxy.Models;
using NeuroScriptProxy.Services;

var builder = WebApplication.CreateBuilder(args);

// Register dependencies
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", p =>
    {
        p.AllowAnyOrigin()
         .AllowAnyMethod()
         .AllowAnyHeader()
         .WithExposedHeaders("X-RateLimit-Limit", "X-RateLimit-Remaining", "Retry-After");
    });
});

builder.Services.AddSingleton<RateLimiter>();
builder.Services.AddSingleton<ILessonGenerator, MockLessonGenerator>();

var app = builder.Build();

app.UseCors("AllowAll");

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
    var configuredApiKey = configuration["NEUROSCRIPT_PROXY_API_KEY"];
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

    // Check rate limit
    var (isAllowed, remaining, retryAfter) = rateLimiter.CheckLimit(effectiveInstallId);
    httpContext.Response.Headers["X-RateLimit-Limit"] = rateLimiter.Limit.ToString();
    httpContext.Response.Headers["X-RateLimit-Remaining"] = remaining.ToString();

    if (!isAllowed)
    {
        httpContext.Response.Headers["Retry-After"] = retryAfter.ToString();
        logger.LogWarning("Rate limit exceeded for InstallId: {InstallId}", effectiveInstallId);

        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/rate-limited",
            Title: "Rate Limit Exceeded",
            Status: 429,
            Detail: $"Rate limit of {rateLimiter.Limit} requests per minute exceeded. Please retry after {retryAfter} seconds.",
            ErrorCode: "RATE_LIMITED"
        ), statusCode: 429, contentType: "application/problem+json");
    }

    // Validate input body
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

    try
    {
        var lesson = await generator.GenerateLessonAsync(request);
        sw.Stop();

        // Privacy-first audit logging: metadata only, never raw notes or card contents
        // Never log lesson titles or note hashes; titles can contain source-note text.
        logger.LogInformation("Generated lesson for Profile: {Profile}, Lines: {LineCount}, Latency: {ElapsedMs}ms",
            request.Profile, request.Lines.Count, sw.ElapsedMilliseconds);

        return Results.Ok(lesson);
    }
    catch (Exception ex)
    {
        sw.Stop();
        logger.LogError(ex, "Error generating study lesson for Profile: {Profile}", request.Profile);

        return Results.Json(new ProblemDetailsDto(
            Type: "https://neuroscript.uet.edu.pk/errors/upstream-error",
            Title: "Generation Failed",
            Status: 502,
            Detail: ex.Message,
            ErrorCode: "UPSTREAM_ERROR"
        ), statusCode: 502, contentType: "application/problem+json");
    }
});

app.Run();
