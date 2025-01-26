function Use-RocketForms {
    param (
        [Parameter(ValueFromPipeline)]
        [string] $PipeCommand = ""
    )

    process {
        $formsDirectory = $global:FormsDirectory ?? "forms"
        $formsPath = "$(Get-Location)/$formsDirectory"
        $pathExists = Test-Path -Path $formsPath -ErrorAction SilentlyContinue

        if(-not ($pathExists)) {
            Write-Host "Forms directory not found" -BackgroundColor Red -ForegroundColor White
            return $PipeCommand
        }

        $tempPath = "$(Get-Location)/.$formsDirectory"
        $tempPathExists = Test-Path -Path $tempPath -ErrorAction SilentlyContinue

        if($tempPathExists) {
            Remove-Item -Path $tempPath -Recurse -Force
        }

        New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
        (Get-Item "$tempPath/").Attributes = "Hidden,System"

        $originalForms = Get-ChildItem -Path $formsPath -Recurse -Include *.psm1
        $originalForms | ForEach-Object {
            $content = Get-Content -Path $_.FullName -Raw
            $content = "Using Module '$global:ROCKET_PUBLIC/RocketForm.psm1'`n" + $content
            New-Item -ItemType File -Path "$tempPath/$($_.Name)" -Value $content -Force 
        }

        $script = ""
        $tempForms = Get-ChildItem -Path $tempPath -Recurse -Include *.psm1
        $tempForms | ForEach-Object {
            $form = $_.FullName
            $script += "Using Module '$form'`n"
        }

        return $PipeCommand + "`n" + $script
    }
}