using System.Text.Json.Serialization;

namespace NeuroScriptProxy.Models;

public record GenerateLessonRequest(
    [property: JsonPropertyName("noteHash")] string NoteHash,
    [property: JsonPropertyName("lines")] List<string> Lines,
    [property: JsonPropertyName("profile")] string Profile,
    [property: JsonPropertyName("mode")] string? Mode,
    [property: JsonPropertyName("clientVersion")] string ClientVersion
);

public record HealthResponse(
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("timestamp")] DateTime Timestamp,
    [property: JsonPropertyName("provider")] string Provider
);

public record ProblemDetailsDto(
    [property: JsonPropertyName("type")] string Type,
    [property: JsonPropertyName("title")] string Title,
    [property: JsonPropertyName("status")] int Status,
    [property: JsonPropertyName("detail")] string Detail,
    [property: JsonPropertyName("errorCode")] string ErrorCode
);

public record LessonDto(
    [property: JsonPropertyName("schemaVersion")] int SchemaVersion,
    [property: JsonPropertyName("title")] string Title,
    [property: JsonPropertyName("meta")] LessonMetaDto Meta,
    [property: JsonPropertyName("conceptMap")] ConceptMapDto ConceptMap,
    [property: JsonPropertyName("flashcards")] List<FlashcardDto> Flashcards,
    [property: JsonPropertyName("rawNotes")] string? RawNotes = null,
    [property: JsonPropertyName("verificationQuestion")] VerificationQuestionDto? VerificationQuestion = null
);

public record LessonMetaDto(
    [property: JsonPropertyName("profile")] string Profile,
    [property: JsonPropertyName("source")] string Source,
    [property: JsonPropertyName("promptVersion")] string PromptVersion
);

public record ConceptMapDto(
    [property: JsonPropertyName("nodes")] List<ConceptNodeDto> Nodes,
    [property: JsonPropertyName("edges")] List<ConceptEdgeDto> Edges
);

public record ConceptNodeDto(
    [property: JsonPropertyName("id")] string Id,
    [property: JsonPropertyName("label")] string Label,
    [property: JsonPropertyName("sourceLines")] List<int> SourceLines
);

public record ConceptEdgeDto(
    [property: JsonPropertyName("from")] string From,
    [property: JsonPropertyName("to")] string To,
    [property: JsonPropertyName("label")] string Label
);

public record FlashcardDto(
    [property: JsonPropertyName("id")] string Id,
    [property: JsonPropertyName("question")] string Question,
    [property: JsonPropertyName("answer")] string Answer,
    [property: JsonPropertyName("sourceLines")] List<int> SourceLines,
    [property: JsonPropertyName("chunks")] List<string>? Chunks = null,
    [property: JsonPropertyName("groundingScore")] double? GroundingScore = null,
    [property: JsonPropertyName("verified")] bool Verified = false
);

public record VerificationQuestionDto(
    [property: JsonPropertyName("question")] string Question,
    [property: JsonPropertyName("sourceLines")] List<int> SourceLines
);
