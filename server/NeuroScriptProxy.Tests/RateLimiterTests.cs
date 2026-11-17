using NeuroScriptProxy.Services;
using Xunit;

namespace NeuroScriptProxy.Tests;

public class RateLimiterTests
{
    [Fact]
    public void CheckLimit_WithinLimit_AllowsRequestsAndDecrementsRemaining()
    {
        var limiter = new RateLimiter(limitPerMinute: 5);
        var installId = "device-test-01";

        for (int i = 1; i <= 5; i++)
        {
            var (isAllowed, remaining, retryAfter) = limiter.CheckLimit(installId);
            Assert.True(isAllowed);
            Assert.Equal(5 - i, remaining);
            Assert.Equal(0, retryAfter);
        }
    }

    [Fact]
    public void CheckLimit_ExceedingLimit_RejectsWithAccurateRetryAfter()
    {
        var limiter = new RateLimiter(limitPerMinute: 3);
        var installId = "device-test-02";

        // Consume 3 requests
        limiter.CheckLimit(installId);
        limiter.CheckLimit(installId);
        limiter.CheckLimit(installId);

        // 4th request must be rejected
        var (isAllowed, remaining, retryAfter) = limiter.CheckLimit(installId);
        Assert.False(isAllowed);
        Assert.Equal(0, remaining);
        Assert.InRange(retryAfter, 1, 60);
    }

    [Fact]
    public void CheckLimit_DifferentInstallIds_DoNotShareQuota()
    {
        var limiter = new RateLimiter(limitPerMinute: 2);
        var deviceA = "device-alpha";
        var deviceB = "device-beta";

        // Exhaust quota for device A
        limiter.CheckLimit(deviceA);
        limiter.CheckLimit(deviceA);
        var (aAllowed, _, _) = limiter.CheckLimit(deviceA);
        Assert.False(aAllowed);

        // Device B should still have its full quota
        var (bAllowed, bRemaining, _) = limiter.CheckLimit(deviceB);
        Assert.True(bAllowed);
        Assert.Equal(1, bRemaining);
    }

    [Fact]
    public async Task CheckLimit_ExpiredWindow_RecoversQuota()
    {
        // Use a short 100ms sliding window
        var limiter = new RateLimiter(limitPerMinute: 1, windowDuration: TimeSpan.FromMilliseconds(100));
        var installId = "device-fast-window";

        var (firstAllowed, _, _) = limiter.CheckLimit(installId);
        Assert.True(firstAllowed);

        var (secondAllowed, _, _) = limiter.CheckLimit(installId);
        Assert.False(secondAllowed);

        // Wait for window to expire
        await Task.Delay(150);

        var (thirdAllowed, _, _) = limiter.CheckLimit(installId);
        Assert.True(thirdAllowed);
    }
}
