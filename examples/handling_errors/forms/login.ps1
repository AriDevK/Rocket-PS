Import-Module .\lib\rocket_form.ps1

class LoginForm : RocketForm {

    [string] $Username
    [string] $Password

    LoginForm() : base() {
        $this.action = "/"
        $this.method = "POST"
        $this.fields = @(
            [RocketField]::new("username", "", [RocketFormType]::Text, "Username", "Username", "username", "form-control", "", "required"),
            [RocketField]::new("password", "", [RocketFormType]::Password, "Password", "Password", "password", "form-control", "", "required"),
            [RocketField]::new("submit", "Login", [RocketFormType]::Submit, "", "", "", "btn btn-primary", "", "")
        )
    }
}