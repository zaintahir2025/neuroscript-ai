using System.Text;
using System.Text.Json;
using NeuroScriptProxy.Models;

namespace NeuroScriptProxy.Services;

public class GeminiLessonGenerator : ILessonGenerator
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<GeminiLessonGenerator> _logger;

    public string ProviderName => $"Google Gemini ({_configuration["Gemini:Model"] ?? "gemini-2.5-flash"})";

    public GeminiLessonGenerator(
        HttpClient httpClient,
        IConfiguration configuration,
        ILogger<GeminiLessonGenerator> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<LessonDto> GenerateLessonAsync(GenerateLessonRequest request, CancellationToken cancellationToken = default)
    {
        var apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY");
        if (string.IsNullOrWhiteSpace(apiKey))
        {
            throw new InvalidOperationException("GEMINI_API_KEY environment variable is not configured.");
        }

        var model = _configuration["Gemini:Model"] ?? "gemini-2.5-flash";
        var endpoint = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";

        var linesText = string.Join("\n", (request.Lines ?? new List<string>())
            .Select((line, idx) => $"[Line {idx + 1}] {line}"));

        var systemPrompt =
            "You are a closed-book educational lesson compiler for neurodivergent learners. " +
            "You MUST only use the facts explicitly stated in the provided notes lines. " +
            "Do NOT hallucinate or extrapolate outside the provided notes. " +
            "Format the output strictly as a valid JSON object matching the requested schema with schemaVersion=1, title, meta, conceptMap, flashcards, rawNotes, and verificationQuestion.";

        var userPrompt = $"Profile: {request.Profile}\n\nNotes:\n{linesText}";

        var requestBody = new
        {
            contents = new[]
            {
                new
                {
                    parts = new object[]
                    {
                        new { text = $"{systemPrompt}\n\n{userPrompt}" }
                    }
                }
            },
            generationConfig = new
            {
                temperature = 0.2,
                responseMimeType = "application/json"
            }
        };

        var jsonContent = new StringContent(
            JsonSerializer.Serialize(requestBody),
            Encoding.UTF8,
            "application/json"
        );

        var response = await _httpClient.PostAsync(endpoint, jsonContent, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            var errText = await response.Content.ReadAsStringAsync(cancellationToken);
            _logger.LogError("Gemini API call failed with status {StatusCode}: {Error}", response.StatusCode, errText);
            throw new HttpRequestException($"Gemini API error: {response.StatusCode}");
        }

        var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
        using var doc = JsonDocument.Parse(responseJson);
        var candidates = doc.RootElement.GetProperty("candidates");
        if (candidates.GetArrayLength() == 0)
        {
            throw new InvalidOperationException("Gemini returned no candidates.");
        }

        var contentText = candidates[0]
            .GetProperty("content")
            .GetProperty("parts")[0]
            .GetProperty("text")
            .GetString();

        if (string.IsNullOrWhiteSpace(contentText))
        {
            throw new InvalidOperationException("Gemini returned empty content text.");
        }

        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var lesson = JsonSerializer.Deserialize<LessonDto>(contentText, options);
        if (lesson == null)
        {
            throw new InvalidOperationException("Failed to deserialize LessonDto from Gemini response.");
        }

        return lesson;
    }
}
