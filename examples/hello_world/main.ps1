$rocket = [RocketServer]::new()

$rocket.Router.Get("/hello", {
    param($httpContext)
    return "Hello World!"
})

$rocket.Launch()
