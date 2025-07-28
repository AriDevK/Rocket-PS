using module ".\RocketRouter.psm1"
using namespace System.Net
using namespace System.Collections.Generic

function Get-FileMimeType($filePath) {
    if ($filePath.EndsWith(".js")) {
        return "text/javascript"
    }

    elseif ($filePath.EndsWith(".css")) {
        return "text/css"
    }

    elseif ($filePath.EndsWith(".html")) {
        return "text/html"
    }

    elseif ($filePath.EndsWith(".png")) {
        return "image/png"
    }

    elseif ($filePath.EndsWith(".jpg")) {
        return "image/jpeg"
    }

    elseif ($filePath.EndsWith(".ico")) {
        return "image/x-icon"
    }

    elseif ($filePath.EndsWith(".svg")) {
        return "image/svg+xml"
    }

    elseif ($filePath.EndsWith(".json")) {
        return "application/json"
    }

    elseif ($filePath.EndsWith(".ttf")) {
        return "font/ttf"
    }

    else {
        return "text/plain"
    }
}

class RocketServer {
    [string] $Port
    [string] $Url
    hidden [RocketRouter] $Router
    hidden [System.Net.HttpListener] $httpListener

    RocketServer() {
        $this.Url = $global:Url ?? "http://localhost"
        $this.Port = $global:Port ?? "8080"
        $this.httpListener = [System.Net.HttpListener]::new()
        $this.Router = [RocketRouter]::new($this)
        $this.httpListener.Prefixes.Add($this.Url + ":" + $this.Port + "/")
        $this.Router.MapDirectory($global:RoutesDirectory ?? "Routes")
    }

    [Void] Launch() {
        # Clear-Host
        Write-Host "-------------------------------------------------" -BackgroundColor DarkBlue -ForegroundColor White
        Write-Host "🚀 Starting server on $($this.Url):$($this.Port)"
        Write-Host "-------------------------------------------------" -BackgroundColor DarkBlue -ForegroundColor White
        Write-Host ""
        Write-Host "Press Ctrl+C to stop the server"
        Write-Host "Requests received:"


        try {
            $global:ROCKET_MIDDLEWARES_ON_LAUNCH | ForEach-Object {
                $_.Invoke($this)
            }

            $global:Server = $this
            $handleRequest = {
                [cmdletbinding()]
                param($result)

                [System.Net.HttpListener]$listener = $result.AsyncState;
                $ctx = $listener.EndGetContext($result);
                $httpContext = [RocketHttpContext]::new($ctx)
                $httpMethod = $httpContext.Request.HttpMethod

                $global:ROCKET_MIDDLEWARES_ON_REQUEST | ForEach-Object {
                    $_.Invoke($httpContext.Request, $httpContext.Response)
                }

                $path = $httpContext.Request.Url.AbsolutePath
                $auxFilePath = $httpContext.Request.Url.AbsolutePath
                $auxFilePath = $auxFilePath.Replace("/", "\")
                $auxFilePath = $auxFilePath.TrimStart("\")
                $auxFilePath = $auxFilePath.TrimEnd("\")
                $loc = Get-Location

                $action = $global:Server.Router.GetAction($path, $httpMethod, $httpContext.Request)

                if ($action -ne $null) {
                    Write-Host "[$(Get-Date -Format "HH:mm:ss")] ($($httpContext.Response.StatusCode + " " + $httpContext.Reponse.StatusDescription)) $($httpContext.Request.Url) "
                    $response = $action.Invoke($httpContext.Request, $httpContext.Response)
                    $response = $response -as [Array]

                    if($response -and $response.GetType().Name -eq "Object[]") {

                        $httpResponse = $httpContext.Response

                        if($response.length -eq 2) {
                            $httpResponse.StatusCode = $response[1]
                        }
                        else {
                            $httpResponse.StatusCode = [System.Net.HttpStatusCode]::OK
                        }

                        if($response.length -eq 3) {
                            $httpResponse.ContentType = $response[2]
                        }
                        else {
                            $httpResponse.ContentType = "text/html"
                        }

                        $buffer = [Text.Encoding]::UTF8.GetBytes($response[0])
                        $httpResponse.ContentLength64 = $buffer.length
                        $httpResponse.OutputStream.Write($buffer, 0, $buffer.length)
                        $httpResponse.Close()
                    } elseif ($httpContext.Response.StatusCode -eq [System.Net.HttpStatusCode]::Redirect) {
                        $httpResponse = $httpContext.Response
                        $httpResponse.StatusCode = [System.Net.HttpStatusCode]::Redirect
                        $httpResponse.Close()
                        Write-Host "🔀 [$(Get-Date -Format "HH:mm:ss")] ($($httpContext.Response.StatusCode + " " + $httpContext.Reponse.StatusDescription)) $($httpContext.Request.Url) "
                    }
                }
                elseif ($global:ServeStaticFiles -and (Test-Path "$loc/$auxFilePath")){
                    $filePath = $httpContext.Request.Url.AbsolutePath.Replace("/public/", "/public/")
                    $filePathSeparator = "/"

                    # Fix for Windows path
                    if (-not (Get-ChildItem Env:COMMAND_MODE -ErrorAction SilentlyContinue).Value.StartsWith("unix")) {
                        $filePathSeparator = "\"
                    }

                    $filePath = $filePath.Replace("/", $filePathSeparator)
                    $filePath = $filePath.TrimStart($filePathSeparator)
                    $filePath = $filePath.TrimEnd($filePathSeparator)

                    $httpResponse = $httpContext.Response
                    # $httpResponse.ContentType = (Get-FileMimeType($filePath))

                    if ($filePath.EndsWith(".js")) {
                        $httpResponse.ContentType = "text/javascript"
                    }

                    elseif ($filePath.EndsWith(".css")) {
                        $httpResponse.ContentType = "text/css"
                    }

                    elseif ($filePath.EndsWith(".html")) {
                        $httpResponse.ContentType = "text/html"
                    }

                    elseif ($filePath.EndsWith(".png")) {
                        $httpResponse.ContentType = "image/png"
                    }

                    elseif ($filePath.EndsWith(".jpg")) {
                        $httpResponse.ContentType = "image/jpeg"
                    }

                    elseif ($filePath.EndsWith(".ico")) {
                        $httpResponse.ContentType = "image/x-icon"
                    }

                    elseif ($filePath.EndsWith(".svg")) {
                        $httpResponse.ContentType = "image/svg+xml"
                    }

                    elseif ($filePath.EndsWith(".json")) {
                        $httpResponse.ContentType = "application/json"
                    }

                    elseif ($filePath.EndsWith(".ttf")) {
                        $httpResponse.ContentType = "font/ttf"
                    }

                    else {
                        $httpResponse.ContentType = "text/plain"
                    }


                    try {
                        $httpResponse.StatusCode = [System.Net.HttpStatusCode]::OK
                        $bytes = [System.IO.File]::ReadAllBytes($filePath)
                        $httpResponse.OutputStream.Write($bytes, 0, $bytes.Length)
                        $httpResponse.Close()
                        Write-Host "[$(Get-Date -Format "HH:mm:ss")] ($($httpContext.Response.StatusCode + " " + $httpContext.Reponse.StatusDescription)) $($httpContext.Request.Url) "
                    }
                    catch {
                        Write-Host "💥 Error: $($_.Exception.Message)"
                    }
                }
                else {
                    $response = "<h1>404 Not Found</h1>"

                    if ($global:Server.Router.HasErrorHandlers()) {
                        $notFoundAction = $global:Server.Router.GetErrorHandler([System.Net.HttpStatusCode]::NotFound)

                        if ($notFoundAction) {
                            $notFoundResponse = $notFoundAction.Invoke($httpContext.Request, $httpContext.Response)
                            $notFoundResponse = $notFoundResponse -as [Array]

                            if($notFoundResponse -and $notFoundResponse.GetType().Name -eq "Object[]") {
                                $response = $notFoundResponse[0]
                            }
                        }

                        $httpResponse = $httpContext.Response
                        $httpResponse.ContentType = "text/html"
                        $httpResponse.StatusCode = [System.Net.HttpStatusCode]::NotFound
                        Write-Host "💥 [$(Get-Date -Format "HH:mm:ss")] ($($httpContext.Response.StatusCode + " " + $httpContext.Reponse.StatusDescription)) $($httpContext.Request.Url) "

                        $buffer = [Text.Encoding]::UTF8.GetBytes($response)
                        $httpResponse.ContentLength64 = $buffer.length
                        $httpResponse.OutputStream.Write($buffer, 0, $buffer.length)
                        $httpResponse.Close()
                    }
                }
            }

            $this.httpListener.Start()
            $context = $this.httpListener.BeginGetContext((New-ScriptBlockCallback -Callback $handleRequest), $this.httpListener)

            while ($this.httpListener.IsListening) {
                # If ($context.IsCompleted -eq $true) {
                $this.httpListener.BeginGetContext((New-ScriptBlockCallback -Callback $handleRequest), $this.httpListener)
                # }
            }

        }
        catch {
            try{
                $this.Stop()
            }
            catch {
                Write-Host "💥 Error: $($_.Exception.Message)"
            }
            Write-Host "💥 Error: $($_.Exception.Message)"
        }
    }

    [Void] Stop() {
        $this.httpListener.Stop()
    }

    [RocketRouter] GetRouter() {
        return $this.Router
    }
}


function New-ScriptBlockCallback 
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$Callback
    )

    # Is this type already defined?
    if (-not ( 'CallbackEventBridge' -as [type])) {
        Add-Type @' 
            using System; 

            public sealed class CallbackEventBridge { 
                public event AsyncCallback CallbackComplete = delegate { }; 

                private CallbackEventBridge() {} 

                private void CallbackInternal(IAsyncResult result) { 
                    CallbackComplete(result); 
                } 

                public AsyncCallback Callback { 
                    get { return new AsyncCallback(CallbackInternal); } 
                } 

                public static CallbackEventBridge Create() { 
                    return new CallbackEventBridge(); 
                } 
            } 
'@
    }
    $bridge = [callbackeventbridge]::create()
    Register-ObjectEvent -InputObject $bridge -EventName callbackcomplete -Action $Callback -MessageData $args > $null
    $bridge.Callback
}


class RocketHttpResponse {
    RocketHttpResponse($httpResponse) {
        $httpResponse.PSObject.Properties | ForEach-Object {
            $this | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
        }

        $httpResponse.PSObject.Methods | ForEach-Object {
            $this | Add-Member -MemberType ScriptMethod -Name $_.Name -Value {
                $_.Value
            }
        }
    }

    # [void] WriteResponse([string] $content) {
    #     $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
    #     $this.Response.ContentLength64 = $buffer.Length
    #     $stream = $this.OutputStream
    #     $stream.Write($buffer, 0, $buffer.Length)
    #     $stream.Close()
    # }
}


class RocketHttpRequest {
    [PSCustomObject] $Body = @{}
    [HashTable] $Form = @{}
    [HashTable] $Params = @{}

    RocketHttpRequest($httpRequest) {
        $httpRequest.PSObject.Properties | ForEach-Object {
            $this | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
        }

        $httpRequest.PSObject.Methods | ForEach-Object {
            $this | Add-Member -MemberType ScriptMethod -Name $_.Name -Value {
                $_.Value
            }
        }


        if (-not $httpRequest.InputStream) { return }
        $requestBody = $httpRequest.InputStream
        $encoding = $httpRequest.ContentEncoding
        $reader = [System.IO.StreamReader]::new($requestBody, $encoding)
        $data = $reader.ReadToEnd()
        if (-not $data) { return }

        $contentType = $httpRequest.ContentType

        if ($contentType -eq "application/x-www-form-urlencoded") {
            $this.Form = @{}
            $dataFields = $data.Split("&")
            $dataFields | ForEach-Object {
                $field = $_.Split("=")
                $this.Form[$field[0]] = $field[1].Replace("+", " ")
            }
        }
        elseif ($contentType -eq "application/json") {
            $this.Body = ConvertFrom-Json $data
        }

        $this.Params = @{}
    }

    [bool] HasParam([string] $param) {
        return $this.Params.ContainsKey($param)
    }

    [bool] HasBody([string] $param) {
        return $this.Body.ContainsKey($param)
    }

    [bool] HasForm([string] $param) {
        return $this.Form.ContainsKey($param)
    }
}



class RocketHttpContext {
    [RocketHttpRequest] $Request
    [System.Net.HttpListenerResponse] $Response

    RocketHttpContext([System.Net.HttpListenerContext] $ctx) {
        $this.Request = [RocketHttpRequest]::new($ctx.Request)
        $this.Response = $ctx.Response
    }
}