using NeuroScriptProxy.Models;

namespace NeuroScriptProxy.Services;

public interface ILessonGenerator
{
    string ProviderName { get; }
    Task<LessonDto> GenerateLessonAsync(GenerateLessonRequest request, CancellationToken cancellationToken = default);
}
