function Register-MiddlewareResource {
    if ($null -eq $global:ROCKET_MIDDLEWARES_ON_LAUNCH) {
        $global:ROCKET_MIDDLEWARES_ON_LAUNCH = @()
    }

    if ($null -eq $global:ROCKET_MIDDLEWARES_ON_REQUEST) {
        $global:ROCKET_MIDDLEWARES_ON_REQUEST = @()
    }
}