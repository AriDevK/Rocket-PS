class Swagger : System.Attribute {
    Swagger() {}
}

function Has-Attribute {
    param (
        [string]$FunctionName,
        [Type]$AttributeType
    )

    $func = Get-Command $FunctionName -ErrorAction SilentlyContinue
    if (-not $func) {
        return $false
    }

    # Obtener atributos de la función
    $attributes = $func.ScriptBlock.Attributes

    # Verificar si tiene el atributo especificado
    foreach ($attr in $attributes) {
        if ($attr.GetType() -eq $AttributeType) {
            return $true
        }
    }

    return $false
}

function Generate-Swagger {
    Param($server)

    try {

        $docs = [ordered]@{
            "openapi" = "3.0.0";
            "info" = @{
                "title" = "$($global:Swagger.Info.Title)";
                "description" = "$($global:Swagger.Info.Description)";
                "version" = "$($global:Swagger.Info.Version)";
                "termsOfService" = "$($global:Swagger.Info.TermsOfService)";
                "contact" = @{
                    "name" = "$($global:Swagger.Info.Contact.Name)";
                    "email" = "$($global:Swagger.Info.Contact.Email)";
                }; 
                "license" = @{
                    "name" = "$($global:Swagger.Info.License.Name)";
                    "url" = "$($global:Swagger.Info.License.Url)";
                }
            };
            "servers" = @()
            "paths" = @{}
        }
        
        $global:Swagger.Servers.ForEach({
            $docs.servers += @{
                "url" = $_.Url;
                "description" = $_.Description;
            }
        })
        
        

        $getHandlers = $server.GetRouter().getRoutes
        $postHandlers = $server.GetRouter().postRoutes
        $putHandlers = $server.GetRouter().putRoutes
        $deleteHandlers = $server.GetRouter().deleteRoutes
        
        $getRoutes = $getHandlers.GetEnumerator() | Select-Object -Property Key
        $postRoutes = $postHandlers.GetEnumerator() | Select-Object -Property Key
        $putRoutes = $putHandlers.GetEnumerator() | Select-Object -Property Key
        $deleteRoutes = $deleteHandlers.GetEnumerator() | Select-Object -Property Key
        $globalRoutes = $getRoutes + $postRoutes + $putRoutes + $deleteRoutes | Sort-Object -Property Key -Unique


        $globalRoutes.ForEach({
            $key = $_.Key
            $route = $_.Value
            $get = $getHandlers[$key]
            $post = $postHandlers[$key]
            $put = $putHandlers[$key]
            $delete = $deleteHandlers[$key]


            if ($get -eq $null -and $post -eq $null -and $put -eq $null -and $delete -eq $null) {
                return
            }
        
            $docs.paths += [ordered]@{
                "$($key)" = [ordered]@{}
            }
        
            if ($get -ne $null) {
                $functionName = $key.Replace("/", "_1GET")
                Set-Item -Path "Function:\$functionName" -Value $get
        
                $willBeMapped = Has-Attribute -FunctionName $functionName -AttributeType ([Swagger])
                if ($willBeMapped) {
                    $funcDocs = (Get-Help $functionName -Full)
                    $summary = ""
                    if(-not $funcDocs.Synopsis.Contains("`n$functionName")) { 
                        $summary = $funcDocs.Synopsis 
                    }
                    $description = if($funcDocs.Description.Count -gt 0) { $funcDocs.Description[0].Text } else { "" }
                    $response = $funcDocs.returnValues.returnValue.type.name.Split("`n")
                    $docs.paths["$($key)"].get = [ordered]@{
                        "summary" = $summary;
                        "description" = $description;
                        "parameters" = @();
                        "responses" = @{}
                    }

                    $key.Split("/") | Where-Object { $_ -match '\{.*\}' } | Select-Object -Property @{Name="Name";Expression={$_ -replace '\{|\}'}} | ForEach-Object {
                        $docs.paths["$($key)"].get.parameters += @{
                            "name" = $_.Name;
                            "in" = "path";
                            "required" = $true;
                            "schema" = @{
                                "type" = "string"
                            }
                        }
                    } 
        
                    if($response.Count -gt 0) {
                        $response.ForEach({
                            if (-not $_.Contains("-")) {
                                return
                            }
        
                            $status = $_.Split("-")[0].Trim()
                            $description = $_.Split("-")[1].Trim()
                            $docs.paths["$($key)"].get.responses += @{
                                "$status" = @{
                                    "description" = $description
                                }
                            }
                        })
                    }
        
                    if ($docs.paths["$($key)"].get.responses.Count -eq 0) {
                        $docs.paths["$($key)"].get.responses += @{
                            "200" = @{
                                "description" = "The request was successful"
                            }
                        }
                    }
                }
            }
        
            if ($post -ne $null) {
                $functionName = $key.Replace("/", "_1POST")
                Set-Item -Path "Function:\$functionName" -Value $post
                
                $willBeMapped = Has-Attribute -FunctionName $functionName -AttributeType ([Swagger])
                if ($willBeMapped) {
                    $funcDocs = (Get-Help $functionName -Full)
                    $summary = ""
                    if(-not $funcDocs.Synopsis.Contains("`n$functionName")) { 
                        $summary = $funcDocs.Synopsis 
                    }
                    $description = if($funcDocs.Description.Count -gt 0) { $funcDocs.Description[0].Text } else { "" }
                    $response = $funcDocs.returnValues.returnValue.type.name.Split("`n")
                    $docs.paths["$($key)"].post = [ordered]@{
                        "summary" = $summary;
                        "description" = $description;
                        "parameters" = @();
                        "responses" = @{
                        }
                    }
        
                    if($response.Count -gt 0) {
                        $response.ForEach({
                            if (-not $_.Contains("-")) {
                                return
                            }
        
                            $status = $_.Split("-")[0].Trim()
                            $description = $_.Split("-")[1].Trim()
                            $docs.paths["$($key)"].post.responses += @{
                                "$status" = @{
                                    "description" = $description
                                }
                            }
                        })
                    }
        
                    if ($docs.paths["$($key)"].post.responses.Count -eq 0) {
                        $docs.paths["$($key)"].post.responses += @{
                            "200" = @{
                                "description" = "The request was successful"
                            }
                        }
                    }
                }
            }
        
            if ($put -ne $null) {
                $functionName = $key.Replace("/", "_1PUT")
                Set-Item -Path "Function:\$functionName" -Value $put
        
                $willBeMapped = Has-Attribute -FunctionName $functionName -AttributeType ([Swagger])
                if ($willBeMapped) {
                    $funcDocs = (Get-Help $functionName -Full)
                    $summary = ""
                    if(-not $funcDocs.Synopsis.Contains("`n$functionName")) { 
                        $summary = $funcDocs.Synopsis 
                    }
                    $description = if($funcDocs.Description.Count -gt 0) { $funcDocs.Description[0].Text } else { "" }
                    $response = $funcDocs.returnValues.returnValue.type.name.Split("`n")
                    $docs.paths["$($key)"].put = [ordered]@{
                        "summary" = $summary;
                        "description" = $description;
                        "parameters" = @();
                        "responses" = @{
                        }
                    }
        
                    if($response.Count -gt 0) {
                        $response.ForEach({
                            if (-not $_.Contains("-")) {
                                return
                            }
        
                            $status = $_.Split("-")[0].Trim()
                            $description = $_.Split("-")[1].Trim()
                            $docs.paths["$($key)"].put.responses += @{
                                "$status" = @{
                                    "description" = $description
                                }
                            }
                        })
                    }
        
                    if ($docs.paths["$($key)"].put.responses.Count -eq 0) {
                        $docs.paths["$($key)"].put.responses += @{
                            "200" = @{
                                "description" = "The request was successful"
                            }
                        }
                    }
                }
            }
        
            if ($delete -ne $null) {
                $functionName = $key.Replace("/", "_1DELETE")
                Set-Item -Path "Function:\$functionName" -Value $delete
        
                $willBeMapped = Has-Attribute -FunctionName $functionName -AttributeType ([Swagger])
                if ($willBeMapped) {
                    $funcDocs = (Get-Help $functionName -Full)
                    $summary = ""
                    if(-not $funcDocs.Synopsis.Contains("`n$functionName")) { 
                        $summary = $funcDocs.Synopsis 
                    }
                    $description = if($funcDocs.Description.Count -gt 0) { $funcDocs.Description[0].Text } else { "" }
                    $response = $funcDocs.returnValues.returnValue.type.name.Split("`n")
                    $docs.paths["$($key)"].delete = [ordered]@{
                        "summary" = $summary;
                        "description" = $description;
                        "parameters" = @();
                        "responses" = @{
                        }
                    }
        
                    if($response.Count -gt 0) {
                        $response.ForEach({
                            if (-not $_.Contains("-")) {
                                return
                            }
        
                            $status = $_.Split("-")[0].Trim()
                            $description = $_.Split("-")[1].Trim()
                            $docs.paths["$($key)"].delete.responses += @{
                                "$status" = @{
                                    "description" = $description
                                }
                            }
                        })
                    }
        
                    if ($docs.paths["$($key)"].delete.responses.Count -eq 0) {
                        $docs.paths["$($key)"].delete.responses += @{
                            "200" = @{
                                "description" = "The request was successful"
                            }
                        }
                    }
                }
            }
        
        })

        ConvertTo-Json $docs -Depth 100 | Out-File "./$($global:Swagger.OutputDir)/swagger.json"
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

$global:ROCKET_MIDDLEWARES_ON_LAUNCH += {
    param($rocket)
    # echo $rocket
    Generate-Swagger -server $rocket
}
