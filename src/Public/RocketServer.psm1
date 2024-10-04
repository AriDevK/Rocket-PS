using module ".\RocketRouter.psm1"
using namespace System.Net
using namespace System.Collections.Generic

class RocketServer {
    [string] $Port
    [string] $Url
    [RocketRouter] $Router
    hidden [System.Net.HttpListener] $httpListener


    RocketServer() {
        $this.Url = $global:Url
        $this.Port = $global:Port
        $this.httpListener = [System.Net.HttpListener]::new()
        $this.Router = [RocketRouter]::new()
        $this.httpListener.Prefixes.Add($this.Url + ":" + $this.Port + "/")
    }

    Launch() {
        # Clear-Host
        Write-Host "-------------------------------------------------" -BackgroundColor DarkBlue -ForegroundColor White
        Write-Host "🚀 Starting server on $($this.Url):$($this.Port)"
        Write-Host "-------------------------------------------------" -BackgroundColor DarkBlue -ForegroundColor White
        Write-Host ""
        Write-Host "Press Ctrl+C to stop the server"
        Write-Host "Request received:"

        while ($true) {

            # read key press to stop server
            if ([System.Console]::KeyAvailable) {
                $key = [System.Console]::ReadKey($true)
                if ($key.Key -eq "C" -and ($key.Modifiers -band [System.ConsoleModifiers]::Control)) {
                    Write-Host "Stopping server..."
                    $this.Stop()
                    break
                }
            }

            # start basic web server
            $this.httpListener.Start()
            $httpContext = $this.httpListener.GetContext()
            $httpMethod = $httpContext.Request.HttpMethod

            
            $path = $httpContext.Request.Url.AbsolutePath
            $auxFilePath = $httpContext.Request.Url.AbsolutePath
            $auxFilePath = $auxFilePath.Replace("/", "\")
            $auxFilePath = $auxFilePath.TrimStart("\")
            $auxFilePath = $auxFilePath.TrimEnd("\")
            $loc = Get-Location

            $action = $this.Router.GetAction($path, $httpMethod)
            if ($action) {
                Write-Host "[$(Get-Date -Format "HH:mm:ss")] ($($httpContext.Response.StatusCode + " " + $httpContext.Reponse.StatusDescription)) $($httpContext.Request.Url) "
                $response = $action.Invoke($httpContext)

                if($response -and $response.GetType().Name -eq "Object[]") {
                    $httpResponse = $httpContext.Response
                    $httpResponse.ContentType = "text/html"

                    if($response.length -eq 2) {
                        $httpResponse.StatusCode = $response[1]
                    }
                    else {
                        $httpResponse.StatusCode = [System.Net.HttpStatusCode]::OK
                    }

                    $buffer = [Text.Encoding]::UTF8.GetBytes($response[0])
                    $httpResponse.ContentLength64 = $buffer.length
                    $httpResponse.OutputStream.Write($buffer, 0, $buffer.length)
                }
            }
            elseif ($global:ServeStaticFiles -and $httpMethod -eq "GET" -and (Test-Path "$loc/$auxFilePath")){
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

                if ($filePath.EndsWith(".js")) {
                    $httpResponse.ContentType = "text/javascript"
                }

                elseif ($filePath.EndsWith(".css")) {
                    $httpResponse.ContentType = "text/css"
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


                $httpResponse.StatusCode = [System.Net.HttpStatusCode]::OK
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                Write-Host "[$(Get-Date -Format "HH:mm:ss")] ($($httpContext.Response.StatusCode + " " + $httpContext.Reponse.StatusDescription)) $($httpContext.Request.Url) "
                $httpResponse.OutputStream.Write($bytes, 0, $bytes.Length)
            }
            else {
                $response = "<h1>404 Not Found</h1>"

                if ($this.Router.HasErrorHandlers()) {
                    $notFoundAction = $this.Router.GetErrorHandler([System.Net.HttpStatusCode]::NotFound)

                    if ($notFoundAction) {
                        $notFoundResponse = $notFoundAction.Invoke($httpContext)

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
                }
            }
        }
    }

    Stop() {
        $this.httpListener.Stop()
    }
}
