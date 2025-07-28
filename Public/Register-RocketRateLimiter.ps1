function Register-RocketRateLimiter {
    param($request, $response)

    if ($global:ROCKET_EXTENSION_RATELIMITER_MEMORYCACHE -eq $null) {
        $global:ROCKET_EXTENSION_RATELIMITER_MEMORYCACHE = [System.Runtime.Caching.MemoryCache]::Default
    }

    $global:ROCKET_MIDDLEWARES_ON_REQUEST += {
        param($request, $response)
        $maxRequests = $global:RateLimiter.MaxRequests
        $interval = [TimeSpan]::FromSeconds($global:RateLimiter.Interval)
        $clientIp = $request.RemoteEndPoint.Address.ToString();
        $now = [System.DateTime]::Now
        $requestTimes = $global:ROCKET_EXTENSION_RATELIMITER_MEMORYCACHE.Get($clientIp) ?? [System.Collections.Generic.List[[DateTime]]]::new()
        $requestTimes.RemoveAll({param($t) $t -lt ($now - $interval)});

        if ($requestTimes.Count -ge $maxRequests){
            Write-Host " [$(Get-Date -Format "HH:mm:ss")] "
            $response.StatusCode = [System.Net.HttpStatusCode]::TooManyRequests;
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("Rate limit exceeded. Try again later.");
            $response.OutputStream.Write($buffer, 0, $buffer.Length);
            $response.OutputStream.Close();
            $response.Close();
            Write-Host "🚥 [$(Get-Date -Format "HH:mm:ss")] ($($httpContext.Response.StatusCode + " Rate limit exceeded for $clientIp")) $($httpContext.Request.Url) "
        } else {
            $response.StatusCode = [System.Net.HttpStatusCode]::OK
            $requestTimes.Add($now);
            $global:ROCKET_EXTENSION_RATELIMITER_MEMORYCACHE.Set($clientIp, $requestTimes, [System.DateTimeOffset]::UtcNow.Add($interval));
        }
    }
}