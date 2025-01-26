using module ".\RocketForm.psm1"
using namespace System.Net

class RocketGui {

    Static [Array] Render([string] $Path){
        return @(
            (Invoke-ScoutRender "views/$Path" @{} "views/$global:Template"),
            [System.Net.HttpStatusCode]::OK
        )
    }

    Static [Array] Render([string] $Path, [HashTable] $Context){
        $Context = [RocketGui]::RenderContextForms($Context)
        return @(
            (Invoke-ScoutRender "views/$Path" $Context "views/$global:Template"), 
            [System.Net.HttpStatusCode]::OK
        )
    }

    Static [Array] Render([string] $Path, [System.Net.HttpStatusCode] $HttpStatus){
        return @(
            (Invoke-ScoutRender "views/$Path" @{} "views/$global:Template"),
            $HttpStatus
        )
    }

    Static [Array] Render([string] $Path, [HashTable] $Context, [System.Net.HttpStatusCode] $HttpStatus){
        $Context = [RocketGui]::RenderContextForms($Context)
        
        return @(
            (Invoke-ScoutRender "views/$Path" $Context "views/$global:Template"),
            $HttpStatus
        )
    }

    Static [HashTable] RenderContextForms([HashTable] $context){
        $renderContext = @{}

        foreach($key in $context.Keys){
            $value = $context[$key]
            if($value -is [RocketForm]){
                $renderContext[$key] = $value.Render()
            }
            else {
                $renderContext[$key] = $value
            }
        }
        return $renderContext
    }
}