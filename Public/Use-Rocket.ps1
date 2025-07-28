function Use-Rocket {
    param (
        [Parameter(ValueFromPipeline)]
        [string] $PipeCommand = ""
    )

    begin {
        Register-PublicPath
        # Register-MiddlewareResource
    }

    process {
        $mainScriptPath = pwd;
        if (Test-Path "$mainScriptPath/config.ps1") {
            Import-Module "$mainScriptPath/config.ps1"
        } elseif (Test-Path "$mainScriptPath/config.json") {
            $json = Get-Content "$mainScriptPath/config.json" | ConvertFrom-Json
            $json.PSObject.Properties | ForEach-Object {
                Set-Variable $_.Name -Value $_.Value -Scope Global -Option ReadOnly -Force
            }
        } else {
            Write-Host "[ERROR] No configuration file found" -ForegroundColor Red
            exit
        }
        
        $script = "Using Module '$global:ROCKET_PUBLIC/RocketRouter.psm1'`n"
        $script += "Using Module '$global:ROCKET_PUBLIC/RocketServer.psm1'`n"
        return $PipeCommand + "`n" + $script
    }
}