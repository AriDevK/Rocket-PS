function Use-Rocket {
    param (
        [Parameter(ValueFromPipeline)]
        [string] $PipeCommand = ""
    )

    begin {
        Register-PublicPath
    }

    process {
        $script = "Using Module '$global:ROCKET_PUBLIC/RocketRouter.psm1'`n"
        $script += "Using Module '$global:ROCKET_PUBLIC/RocketServer.psm1'`n"
        return $PipeCommand + "`n" + $script
    }
}