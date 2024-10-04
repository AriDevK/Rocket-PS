using module ".\RocketForm.psm1"
using namespace System.Net

class RocketGui {
    Static [string] Render([string] $Path){
        return @(
            (Invoke-EpsTemplate -Path "views/$Path" -Safe),
            [System.Net.HttpStatusCode]::OK
        )
    }

    Static [string] Render([string] $Path, [HashTable] $Context){
        $viewContext = [RocketGui]::RenderContextForms($Context)

        if($global:Template -eq "" -or $null -eq $global:Template ){
            return @(
                (Invoke-EpsTemplate -Path "views/$path" -binding $viewContext -Safe), [System.Net.HttpStatusCode]::OK
            )
        }

        $content = (Invoke-EpsTemplate -Path "views/$Path" -binding $viewContext -Safe)
        $c = @{
            "content" = $content
            "ProjectName" = $global:ProjectName
            "PageTitle" = $context["PageTitle"]
        }

        return @(
            (Invoke-EpsTemplate -Path "views/layout.eps" -binding $c -Safe), [System.Net.HttpStatusCode]::OK
        )
    }

    Static [string] Render([string] $Path, [System.Net.HttpStatusCode] $HttpStatus){
        return @(
            (Invoke-EpsTemplate -Path "views/$Path" -Safe),
            $HttpStatus
        )
    }

    Static [string] Render([string] $Path, [HashTable] $Context, [System.Net.HttpStatusCode] $HttpStatus){
        return @(
            (Invoke-EpsTemplate -Path "views/$Path" -Safe),
            [System.Net.HttpStatusCode]::OK
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