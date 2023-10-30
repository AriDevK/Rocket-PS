$rocket = [RocketServer]::new()

$rocket.Router.Get("/", {
    param($httpContext)

    return [RocketGui]::Render("index.eps", @{
        "PageTitle" = "Home";
        "Msg" = "Hello from template :D"
    })
})

$rocket.Router.Get("/about", {
    param($httpContext)
    return [RocketGui]::Render("about.eps", @{
        "PageTitle" = "About";
    })
})


$rocket.Launch()
