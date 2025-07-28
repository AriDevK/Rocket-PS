function Use-RocketSwagger {
    param (
        [Parameter(ValueFromPipeline)]
        [string] $PipeCommand = ""
    )

    process {
        $script = "Using Module '$global:ROCKET_PUBLIC/RocketSwagger.psm1'`n"
        return $PipeCommand + "`n" + $script
    }
}