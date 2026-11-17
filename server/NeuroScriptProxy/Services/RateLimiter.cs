using System.Collections.Concurrent;

namespace NeuroScriptProxy.Services;

/// <summary>
/// Thread-safe sliding-window rate limiter per installation ID.
/// Tracks request timestamps across a 60-second rolling sliding window,
/// preventing burst gaming at minute boundaries while returning precise
/// Retry-After headers compliant with RFC 6585 and RFC 7231.
/// </summary>
public class RateLimiter
{
    private readonly int _limitPerMinute;
    private readonly TimeSpan _windowDuration;
    private readonly ConcurrentDictionary<string, List<DateTime>> _requests = new();

    public RateLimiter(int limitPerMinute = 20, TimeSpan? windowDuration = null)
    {
        _limitPerMinute = limitPerMinute;
        _windowDuration = windowDuration ?? TimeSpan.FromMinutes(1);
    }

    /// <summary>
    /// Checks whether a request from the given installId is allowed within the sliding window.
    /// </summary>
    /// <param name="installId">Hardware/secure-storage backed unique device installation UUID.</param>
    /// <returns>Tuple of (isAllowed, remainingQuota, retryAfterSeconds)</returns>
    public (bool isAllowed, int remaining, int retryAfterSeconds) CheckLimit(string installId)
    {
        var now = DateTime.UtcNow;
        var windowStart = now - _windowDuration;

        var timestamps = _requests.GetOrAdd(installId, _ => new List<DateTime>());

        lock (timestamps)
        {
            // Evict expired timestamps outside the rolling window
            timestamps.RemoveAll(t => t < windowStart);

            if (timestamps.Count >= _limitPerMinute)
            {
                var oldestInWindow = timestamps.First();
                var retryAfter = Math.Max(1, (int)Math.Ceiling((oldestInWindow + _windowDuration - now).TotalSeconds));
                return (false, 0, retryAfter);
            }

            timestamps.Add(now);
            var remaining = Math.Max(0, _limitPerMinute - timestamps.Count);
            return (true, remaining, 0);
        }
    }

    /// <summary>
    /// Resets all tracked rate limits (primarily for unit test isolation).
    /// </summary>
    public void Reset()
    {
        _requests.Clear();
    }

    public int Limit => _limitPerMinute;
    public TimeSpan WindowDuration => _windowDuration;
}
