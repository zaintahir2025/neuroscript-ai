using System.Collections.Concurrent;

namespace NeuroScriptProxy.Services;

public class RateLimiter
{
    private readonly int _limitPerMinute;
    private readonly ConcurrentDictionary<string, List<DateTime>> _requests = new();

    public RateLimiter(int limitPerMinute = 20)
    {
        _limitPerMinute = limitPerMinute;
    }

    public (bool isAllowed, int remaining, int retryAfterSeconds) CheckLimit(string installId)
    {
        var now = DateTime.UtcNow;
        var windowStart = now.AddMinutes(-1);

        var timestamps = _requests.GetOrAdd(installId, _ => new List<DateTime>());

        lock (timestamps)
        {
            // Clean out old timestamps beyond 1 minute
            timestamps.RemoveAll(t => t < windowStart);

            if (timestamps.Count >= _limitPerMinute)
            {
                var oldestInWindow = timestamps.First();
                var retryAfter = Math.Max(1, (int)(oldestInWindow.AddMinutes(1) - now).TotalSeconds);
                return (false, 0, retryAfter);
            }

            timestamps.Add(now);
            var remaining = Math.Max(0, _limitPerMinute - timestamps.Count);
            return (true, remaining, 0);
        }
    }

    public int Limit => _limitPerMinute;
}
