using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NeuroScriptProxy.Models;
using NeuroScriptProxy.Services;
using Xunit;

namespace NeuroScriptProxy.Tests;

public class ProxyEndpointTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private const string ValidApiKey = "test-secret-key-12345";

    public ProxyEndpointTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureAppConfiguration((_, config) =>
            {
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["NEUROSCRIPT_PROXY_API_KEY"] = ValidApiKey
                });
            });
        });
    }

    [Fact]
    public async Task HealthEndpoint_Returns200OkWithStatus()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal("Healthy", body.GetProperty("status").GetString());
    }

    [Fact]
    public async Task GenerateLesson_MissingApiKey_Returns401Unauthorized()
    {
        var client = _factory.CreateClient();
        var payload = new GenerateLessonRequest(
            NoteHash: "test_hash_01",
            Lines: new List<string> { "Line 1: Cells contain mitochondria." },
            Profile: "Dyslexia",
            Mode: "standard",
            ClientVersion: "0.3.0"
        );

        var response = await client.PostAsJsonAsync("/api/v1/lessons/generate", payload);
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GenerateLesson_ValidApiKey_Returns200OkWithLesson()
    {
        var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Add("X-Api-Key", ValidApiKey);
        client.DefaultRequestHeaders.Add("X-Install-Id", "inst_test_uuid_99");

        var payload = new GenerateLessonRequest(
            NoteHash: "test_hash_photosynthesis",
            Lines: new List<string>
            {
                "Photosynthesis occurs within chloroplasts in green plants.",
                "Chlorophyll pigments capture solar radiant energy."
            },
            Profile: "ADHD",
            Mode: "standard",
            ClientVersion: "0.3.0"
        );

        var response = await client.PostAsJsonAsync("/api/v1/lessons/generate", payload);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        Assert.True(response.Headers.Contains("X-RateLimit-Limit"));
        Assert.True(response.Headers.Contains("X-RateLimit-Remaining"));

        var lesson = await response.Content.ReadFromJsonAsync<LessonDto>();
        Assert.NotNull(lesson);
        Assert.Equal(1, lesson.SchemaVersion);
        Assert.NotEmpty(lesson.Flashcards);
        Assert.NotNull(lesson.ConceptMap);
    }

    [Fact]
    public async Task GenerateLesson_ExceedingLineLimit_Returns413PayloadTooLarge()
    {
        var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Add("X-Api-Key", ValidApiKey);
        client.DefaultRequestHeaders.Add("X-Install-Id", "inst_limit_lines");

        // Generate 205 lines (exceeds 200 line maximum)
        var lines = Enumerable.Range(1, 205).Select(i => $"Line {i}: Note text content.").ToList();
        var payload = new GenerateLessonRequest(
            NoteHash: "too_many_lines_hash",
            Lines: lines,
            Profile: "Autism",
            Mode: "standard",
            ClientVersion: "0.3.0"
        );

        var response = await client.PostAsJsonAsync("/api/v1/lessons/generate", payload);
        Assert.Equal(HttpStatusCode.RequestEntityTooLarge, response.StatusCode);

        var problem = await response.Content.ReadFromJsonAsync<ProblemDetailsDto>();
        Assert.NotNull(problem);
        Assert.Equal("LINE_LIMIT_EXCEEDED", problem.ErrorCode);
    }

    [Fact]
    public async Task GenerateLesson_RateLimitExceeded_Returns429WithRetryAfter()
    {
        // Custom factory with tight 2 req limit
        var customFactory = _factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                services.AddSingleton(new RateLimiter(limitPerMinute: 2));
            });
        });

        var client = customFactory.CreateClient();
        client.DefaultRequestHeaders.Add("X-Api-Key", ValidApiKey);
        var installId = "device-flood-test";
        client.DefaultRequestHeaders.Add("X-Install-Id", installId);

        var payload = new GenerateLessonRequest(
            NoteHash: "burst_hash",
            Lines: new List<string> { "Test note line." },
            Profile: "ADHD",
            Mode: "standard",
            ClientVersion: "0.3.0"
        );

        // 1st and 2nd should pass
        var r1 = await client.PostAsJsonAsync("/api/v1/lessons/generate", payload);
        var r2 = await client.PostAsJsonAsync("/api/v1/lessons/generate", payload);
        Assert.Equal(HttpStatusCode.OK, r1.StatusCode);
        Assert.Equal(HttpStatusCode.OK, r2.StatusCode);

        // 3rd must trigger 429
        var r3 = await client.PostAsJsonAsync("/api/v1/lessons/generate", payload);
        Assert.Equal((HttpStatusCode)429, r3.StatusCode);
        Assert.True(r3.Headers.Contains("Retry-After"));
    }
}
