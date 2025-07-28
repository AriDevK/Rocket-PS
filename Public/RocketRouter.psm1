using namespace System.Net
using namespace System.Collections.Generic

Class RocketRouter{
    hidden [System.Collections.Generic.Dictionary[[string], [ScriptBlock]]] $getRoutes
    hidden [System.Collections.Generic.Dictionary[[string], [ScriptBlock]]] $postRoutes
    hidden [System.Collections.Generic.Dictionary[[string], [ScriptBlock]]] $putRoutes
    hidden [System.Collections.Generic.Dictionary[[string], [ScriptBlock]]] $deleteRoutes
    hidden [System.Collections.Generic.Dictionary[[System.Net.HttpStatusCode], [ScriptBlock]]] $errorRoutes

    RocketRouter ($server) {
        $this.getRoutes = [System.Collections.Generic.Dictionary[[string], [ScriptBlock]]]::new()
        $this.postRoutes = [System.Collections.Generic.Dictionary[[string], [ScriptBlock]]]::new()
        $this.putRoutes = [System.Collections.Generic.Dictionary[[string], [ScriptBlock]]]::new()
        $this.deleteRoutes = [System.Collections.Generic.Dictionary[[string], [ScriptBlock]]]::new()
        $this.errorRoutes = [System.Collections.Generic.Dictionary[[System.Net.HttpStatusCode], [ScriptBlock]]]::new()

        $server.PSObject.Methods.Add(([PSScriptMethod]::new("Get", {
            param($Path, $Action)
            $this.Router.Get($Path, $Action)
        })))

        $server.PSObject.Methods.Add(([PSScriptMethod]::new("Post", {
            param($Path, $Action)
            $this.Router.Post($Path, $Action)
        })))

        $server.PSObject.Methods.Add(([PSScriptMethod]::new("Put", {
            param($Path, $Action)
            $this.Router.Put($Path, $Action)
        })))

        $server.PSObject.Methods.Add(([PSScriptMethod]::new("Delete", {
            param($Path, $Action)
            $this.Router.Delete($Path, $Action)
        })))

        $server.PSObject.Methods.Add(([PSScriptMethod]::new("Group", {
            param($Path, $Group)
            $this.Router.Group($Path, $Group)
        })))

        $server.PSObject.Methods.Add(([PSScriptMethod]::new("ErrorHandler", {
            param($ErrorCode, $Action)
            $this.Router.ErrorHandler($ErrorCode, $Action)
        })))

        $server.PSObject.Methods.Add(([PSScriptMethod]::new("MapDirectory", {
            param($Directory)
            $this.Router.MapDirectory($Directory)
        })))
    }

    [void] Get ($Path, $Action) {
        if ($null -eq $this.getRoutes) {
            $this.getRoutes = [System.Collections.Generic.Dictionary[string,Action]]::new()
        }
        $this.getRoutes.Add($Path, $Action)
    }

    [void] Post($Path, $Action) {
        if ($null -eq $this.postRoutes) {
            $this.postRoutes = [System.Collections.Generic.Dictionary[string,Action]]::new()
        }
        $this.postRoutes.Add($Path, $Action)
    }

    [void] Put($Path, $Action) {
        if ($null -eq $this.putRoutes) {
            $this.putRoutes = [System.Collections.Generic.Dictionary[string,Action]]::new()
        }
        $this.putRoutes.Add($Path, $Action)
    }

    [void] Delete($Path, $Action) {
        if ($null -eq $this.deleteRoutes) {
            $this.deleteRoutes = [System.Collections.Generic.Dictionary[string,Action]]::new()
        }
        $this.deleteRoutes.Add($Path, $Action)
    }

    [void] Group ($Path, $Group){
        foreach ($endpoints in $Group) { # Get the endpoint objects ["/", @{"GET" = {}, "POST" = {}}]
            foreach ($endpoint in $endpoints.Keys){ # Get the endpoint name "/"
                foreach ($methods in $endpoints[$endpoint]){ # Get the methods ["GET" = {}, "POST" = {}]
                    foreach ($httpMethod in $methods.Keys){ # Get the method name "GET"
                        $uri = "/{0}{1}" -f $Path, $endpoint

                        if($httpMethod -eq "GET"){
                            $this.Get($uri, $methods[$httpMethod])
                        }

                        elseif($httpMethod -eq "POST"){
                            $this.Post($uri, $methods[$httpMethod])
                        }

                        elseif($httpMethod -eq "PUT"){
                            $this.Put($uri, $methods[$httpMethod])
                        }

                        elseif($httpMethod -eq "DELETE"){
                            $this.Delete($uri, $methods[$httpMethod])
                        }
                    }
                }
            }
        }
    }

    [void] ErrorHandler ([System.Net.HttpStatusCode] $ErrorCode, $Action){
        if ($null -eq $this.errorRoutes) {
            $this.errorRoutes = [System.Collections.Generic.Dictionary[[System.Net.HttpStatusCode], [ScriptBlock]]]::new()
        }
        $this.errorRoutes.Add($ErrorCode, $Action)
    }


    [ScriptBlock] GetAction ($Path, $HttpMethod, $request){
        if($Path.StartsWith("/$($global:StaticFilesPath)")){
            return $null
        }

        $routes = $null
        if($HttpMethod -eq "GET"){
            $routes = $this.getRoutes
        } elseif($HttpMethod -eq "POST"){
            $routes = $this.postRoutes
        } elseif($HttpMethod -eq "PUT"){
            $routes = $this.putRoutes
        } elseif($HttpMethod -eq "DELETE"){
            $routes = $this.deleteRoutes
        } else {
            return $null
        }


        if ($routes[$Path]){
            return $routes[$Path]
        }

        $dynamicPath = ( 
            $routes.Keys 
            | Where-Object { $_ -ne "/" -and $_.Contains("{") }
            | Sort-Object -Property Lenght -Descending 
            | Where-Object { 
                $Path -match ($_ -Replace '\{[0-9A-z]+\}', '[0-9A-z]+')
            }
            | Select-Object -First 1
        )
        
        if ($dynamicPath -eq $null){
            return $null
        }

        $dynamicRoute = $routes[$dynamicPath]
        if ($dynamicRoute){
            $pathData = $Path -split '/'
            $dynamicPathData = $dynamicPath -split '/'
            $aux = $dynamicPathData | Where-Object { $_ -match '\{.*\}' } | Select-Object -Property @{Name="Index";Expression={$dynamicPathData.IndexOf($_)}}, @{Name='Value';Expression={$pathData[$dynamicPathData.IndexOf($_)]}}
            $aux | ForEach-Object {
                $name = $dynamicPathData[$_.Index] -replace '\{|\}'
                $request.Params[$name] = $_.Value
            }
            return $dynamicRoute
        }


        return $null
    }


    [ScriptBlock] GetErrorHandler([System.Net.HttpStatusCode] $ErrorCode){
        return $this.errorRoutes[$ErrorCode]
    }

    [bool] HasErrorHandlers(){
        return $this.errorRoutes.Count -gt 0
    }
    
    [void] MapDirectory($Directory){
        $routesPath = Get-Location | Join-Path -ChildPath $Directory
        Get-ChildItem -Path $routesPath -Filter *.ps1 | Select-Object -Property Name | ForEach-Object {
            $routes = Import-Module -Name "./routes/$($_.Name)"
            $routeName = $_.Name.Replace(".ps1", "")
            $this.Group($routeName, $routes)
        }
    }
    
}
