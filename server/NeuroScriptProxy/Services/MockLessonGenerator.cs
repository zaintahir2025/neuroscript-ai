using NeuroScriptProxy.Models;

namespace NeuroScriptProxy.Services;

public class MockLessonGenerator : ILessonGenerator
{
    public string ProviderName => "Mock Generator (Phase 3 Baseline)";

    public Task<LessonDto> GenerateLessonAsync(GenerateLessonRequest request, CancellationToken cancellationToken = default)
    {
        var rawLines = request.Lines ?? new List<string>();
        var cleanLines = rawLines
            .Select((text, index) => new { LineNumber = index + 1, Text = text.Trim() })
            .Where(x => !string.IsNullOrWhiteSpace(x.Text))
            .ToList();

        if (cleanLines.Count == 0)
        {
            throw new ArgumentException("No OCR lines were provided for lesson generation.");
        }

        // Determine title
        var firstLine = cleanLines[0].Text;
        var title = firstLine.Length > 40 ? firstLine[..37] + "..." : firstLine;
        if (title.EndsWith(':') || title.EndsWith('.'))
        {
            title = title[..^1];
        }

        var flashcards = new List<FlashcardDto>();
        var nodes = new List<ConceptNodeDto>();
        var edges = new List<ConceptEdgeDto>();

        for (int i = 0; i < cleanLines.Count; i++)
        {
            var item = cleanLines[i];
            var lineNum = item.LineNumber;
            var lineText = item.Text;

            string question;
            string answer;

            if (lineText.Contains(':'))
            {
                var parts = lineText.Split(':', 2);
                question = $"What is {parts[0].Trim()}?";
                answer = parts[1].Trim();
            }
            else if (lineText.Contains(" - "))
            {
                var parts = lineText.Split(new[] { " - " }, 2, StringSplitOptions.None);
                question = $"What defines {parts[0].Trim()}?";
                answer = parts[1].Trim();
            }
            else
            {
                question = $"Explain the concept from line {lineNum}: {Truncate(lineText, 35)}";
                answer = lineText;
            }

            var cardId = $"c{lineNum}";
            flashcards.Add(new FlashcardDto(
                Id: cardId,
                Question: question,
                Answer: answer,
                SourceLines: new List<int> { lineNum },
                Chunks: new List<string> { question, answer },
                GroundingScore: 0.96,
                Verified: true
            ));

            var nodeId = $"n{lineNum}";
            var nodeLabel = lineText.Length > 28 ? lineText[..25] + "..." : lineText;
            nodes.Add(new ConceptNodeDto(
                Id: nodeId,
                Label: nodeLabel,
                SourceLines: new List<int> { lineNum }
            ));
        }

        // Link nodes sequentially with semantic edges
        for (int i = 0; i < nodes.Count - 1; i++)
        {
            var edgeLabel = (i % 3) switch
            {
                0 => "leads to",
                1 => "requires",
                _ => "synthesizes"
            };

            edges.Add(new ConceptEdgeDto(
                From: nodes[i].Id,
                To: nodes[i + 1].Id,
                Label: edgeLabel
            ));
        }

        var verificationQuestion = new VerificationQuestionDto(
            Question: $"Based on line {cleanLines[0].LineNumber}, what is the main topic introduced?",
            SourceLines: new List<int> { cleanLines[0].LineNumber }
        );

        var lesson = new LessonDto(
            SchemaVersion: 1,
            Title: title,
            Meta: new LessonMetaDto(
                Profile: request.Profile ?? "Dyslexia",
                Source: "mock",
                PromptVersion: "v1"
            ),
            ConceptMap: new ConceptMapDto(Nodes: nodes, Edges: edges),
            Flashcards: flashcards,
            RawNotes: string.Join("\n", request.Lines ?? new List<string>()),
            VerificationQuestion: verificationQuestion
        );

        return Task.FromResult(lesson);
    }

    private static string Truncate(string val, int max) =>
        val.Length <= max ? val : val[..max] + "...";
}
