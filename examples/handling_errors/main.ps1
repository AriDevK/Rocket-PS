$rocket = [RocketServer]::new()

$rocket.Router.Get("/hello", {
    param($httpContext)
    return "Hello World!"
})


$rocket.Router.Get("/", {
    param($httpContext)
    $loginForm = $null;
    $user = $null;

    if ($httpContext.Request.Cookies["username"] -ne $null) {
        $user = $httpContext.Request.Cookies["username"].Value
    }
    else {
        $loginForm = [LoginForm]::new()
    }

    return [RocketGui]::Render("index.eps", @{
        "PageTitle" = "Home";
        "loginForm" = $loginForm;
        "user" = $user
    })
})


$rocket.Router.Post("/", {
    param($httpContext)
    $login = [LoginForm]::new()
    $login.LoadDataFromRequest($httpContext.Request)

    if ($login.Username -eq "admin" -and $login.Password -eq "admin") {
        $cookie = [Cookie]::new("username", $login.Username);
        $httpContext.Response.Cookies.Add($cookie);
        return [RocketGui]::Render("success.eps")
    }

    return [RocketGui]::Render("index.eps", @{
        "loginForm" = $login ; 
        "msg" = "Username or password incorrect"
    })
})

$rocket.Launch()





# $rocket.Router.Get("/", {
#     param($httpContext)
#     $loginForm = [LoginForm]::new()

#     return [RocketGui]::Render("index.eps", @{
#         "PageTitle" = "Home"
#         "loginForm" = $loginForm
#     })
# })


# $rocket.Router.Get("/hello", {
#     param($httpContext)
#     return "Hello World!"
# })



# $rocket.Router.Post("/", {
#     param($httpContext)

#     $login= [LoginForm]::new()
#     $login.LoadDataFromRequest($httpContext.Request)

#     if ($login.Username -eq "admin" -and $login.Password -eq "admin") {
#         return [RocketGui]::Render("index.eps", @{"user" = $login.Username}, [HttpStatusCode]::OK)
#     }

#     return [RocketGui]::Render("index.eps", @{"user" = $body.user}, [HttpStatusCode]::Created)
# })


# $rocket.Router.Group("api", @{
#     "/" = @{
#         "GET" = {
#             param($httpContext)
#             $response = "<h1>api GET home</h1>"
#             return @($response, [System.Net.HttpStatusCode]::NotFound)
#         };
#         "POST" = {
#             param($httpContext)
#             $response = "<h1>api POST home</h1>"
#             return @($response, [System.Net.HttpStatusCode]::NotFound)
#         };
#     };

#     "/users" = @{
#         "GET" = {
#             param($httpContext)
#             $response = "<h1>api GET users</h1>"
#             return @($response, [System.Net.HttpStatusCode]::NotFound)
#         };
#     };
# })


$rocket.Router.ErrorHandler([HttpStatusCode]::NotFound, {
    param($httpContext)
    return [RocketGui]::Render("404.eps")
})


$rocket.Router.ErrorHandler([HttpStatusCode]::InternalServerError, {
    param($httpContext)
    return [RocketGui]::Render("500.eps")
})


# $rocket.Launch()


