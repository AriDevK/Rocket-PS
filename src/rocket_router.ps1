using namespace System.Net
using namespace System.Collections.Generic

Class RocketRouter{
    hidden [Dictionary[[string], [Func[[HttpListenerContext],[Array]]]]] $getRoutes
    hidden [Dictionary[[string], [Func[[HttpListenerContext],[Array]]]]] $postRoutes
    hidden [Dictionary[[HttpStatusCode], [Func[[HttpListenerContext],[Array]]]]] $errorRoutes

    RocketRouter () {
        $this.getRoutes = [Dictionary[string,Action]]::new()
        $this.postRoutes = [Dictionary[string,Action]]::new()
        $this.errorRoutes = [Dictionary[[HttpStatusCode], [Func[[HttpListenerContext],[Array]]]]]::new()
    }

    [void] Get ($Path, $Action) {
        if ($null -eq $this.getRoutes) {
            $this.getRoutes = [Dictionary[string,Action]]::new()
        }
        $this.getRoutes.Add($Path, $Action)
    }

    [void] Post($Path, $Action) {
        if ($null -eq $this.postRoutes) {
            $this.postRoutes = [Dictionary[string,Action]]::new()
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

    [void] ErrorHandler ([HttpStatusCode] $ErrorCode, $Action){
        if ($null -eq $this.errorRoutes) {
            $this.errorRoutes = [Dictionary[[HttpStatusCode], [Func[[HttpListenerContext],[Array]]]]]::new()
        }
        $this.errorRoutes.Add($ErrorCode, $Action)
    }


    [Func[[HttpListenerContext],[Array]]] GetAction ($Path, $HttpMethod){
        if($HttpMethod -eq "GET"){
            return $this.getRoutes[$Path]
        }
        # else($HttpMethod -eq "POST"){
            return $this.postRoutes[$Path]
        # }
    }

    
    

    [Func[[HttpListenerContext],[Array]]] GetErrorHandler($ErrorCode){
        return $this.errorRoutes[$ErrorCode]
    }

    [bool] HasErrorHandlers(){
        return $this.errorRoutes -ne $null
    }
    
    # [void] Put($Path, $Action) {
    # }

    # [void] Delete($Path, $Action) {
    # }

    
}