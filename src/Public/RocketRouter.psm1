using namespace System.Net
using namespace System.Collections.Generic

Class RocketRouter{
    hidden [System.Collections.Generic.Dictionary[[string], [Func[[System.Net.HttpListenerContext],[Array]]]]] $getRoutes
    hidden [System.Collections.Generic.Dictionary[[string], [Func[[System.Net.HttpListenerContext],[Array]]]]] $postRoutes
    hidden [System.Collections.Generic.Dictionary[[System.Net.HttpStatusCode], [Func[[System.Net.HttpListenerContext],[Array]]]]] $errorRoutes

    RocketRouter () {
        $this.getRoutes = [System.Collections.Generic.Dictionary[string,Action]]::new()
        $this.postRoutes = [System.Collections.Generic.Dictionary[string,Action]]::new()
        $this.errorRoutes = [System.Collections.Generic.Dictionary[[System.Net.HttpStatusCode], [Func[[System.Net.HttpListenerContext],[Array]]]]]::new()
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
                    }
                }
            }
        }
    }

    [void] ErrorHandler ([System.Net.HttpStatusCode] $ErrorCode, $Action){
        if ($null -eq $this.errorRoutes) {
            $this.errorRoutes = [System.Collections.Generic.Dictionary[[System.Net.HttpStatusCode], [Func[[System.Net.HttpListenerContext],[Array]]]]]::new()
        }
        $this.errorRoutes.Add($ErrorCode, $Action)
    }


    [Func[[System.Net.HttpListenerContext],[Array]]] GetAction ($Path, $HttpMethod){
        if($HttpMethod -eq "GET"){
            return $this.getRoutes[$Path]
        }
        # else($HttpMethod -eq "POST"){
            return $this.postRoutes[$Path]
        # }
    }

    
    

    [Func[[System.Net.HttpListenerContext],[Array]]] GetErrorHandler($ErrorCode){
        return $this.errorRoutes[$ErrorCode]
    }

    [bool] HasErrorHandlers(){
        return $null -ne $this.errorRoutes
    }
    
    # [void] Put($Path, $Action) {
    # }

    # [void] Delete($Path, $Action) {
    # }

    
}