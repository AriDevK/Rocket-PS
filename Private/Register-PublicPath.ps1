function Register-PublicPath {
    if ($null -eq $global:ROCKET_PUBLIC) {
        Import-Module Rocket -Force
        $global:ROCKET_PUBLIC = (Get-module Rocket | Select-Object Path)[0].Path.Replace("Rocket.psm1","Public") 
    }

    if ($null -eq $global:ROCKET_MIDDLEWARES_ON_LAUNCH) {
        $global:ROCKET_MIDDLEWARES_ON_LAUNCH = @()
    }

    if ($null -eq $global:ROCKET_MIDDLEWARES_ON_REQUEST) {
        $global:ROCKET_MIDDLEWARES_ON_REQUEST = @()
    }
}