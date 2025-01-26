function Use-RocketGui {
    param (
        [Parameter(ValueFromPipeline)]
        [string] $PipeCommand = ""
    )

    process {
        $script = "Using Module '$global:ROCKET_PUBLIC/RocketForm.psm1'`n"
        $script += "Using Module '$global:ROCKET_PUBLIC/RocketGui.psm1'`n"
        return $PipeCommand + "`n" + $script
    }
}