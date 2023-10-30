$rocket = [RocketServer]::new()


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
