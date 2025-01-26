
enum RocketFormType {
    Text
    Password
    Checkbox
    Radio
    Select
    File
    Submit
    Reset
    Button
    Image
    Email
    Url
    Number
    Range
    Date
    Month
    Week
    Time
    DateTimeLocal
    Color
}

Class RocketField {
    [string] $name
    [string] $value
    [RocketFormType] $formType
    [string] $label
    [string] $placeholder
    [string] $id
    [string] $class
    [string] $style
    [string] $required
    [string] $disabled
    [string] $readonly

    RocketField($_name, $_value, $_formType, $_label, $_placeholder, $_id, $_class, $_style, $_required) {
        $this.name = $_name
        $this.value = $_value
        $this.formType = $_formType
        $this.label = $_label
        $this.placeholder = $_placeholder
        $this.id = $_id
        $this.class = $_class
        $this.style = $_style
        $this.required = $_required
        $this.disabled = $false
        $this.readonly = $false
    }


    RocketField($_name, $_value, $_formType, $_label, $_placeholder, $_id, $_class, $_style, $_required, $_disabled, $_readonly) {
        $this.name = $_name
        $this.value = $_value
        $this.formType = $_formType
        $this.label = $_label
        $this.placeholder = $_placeholder
        $this.id = $_id
        $this.class = $_class
        $this.style = $_style
        $this.required = $_required
        $this.disabled = $_disabled
        $this.readonly = $_readonly
    }


    [string] Render(){
        if($this.formType -eq [RocketFormType]::Text){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='text' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Password){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='password' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Checkbox){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='checkbox' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Radio){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='radio' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Select){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><select name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></select></div>"
        }
        elseif($this.formType -eq [RocketFormType]::File){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='file' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Submit){
            return "<div class='form-group'><input type='submit' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Reset){
            return "<div class='form-group'><input type='reset' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Button){
            return "<div class='form-group'><button type='button' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'>" + $this.label + "</button></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Hidden){
            return "<div class='form-group'><input type='hidden' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Image){
            return "<div class='form-group'><input type='image' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Email){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='email' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Url){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='url' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + $( If ($this.readonly) { "readonly" } )+ "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Number){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='number' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' min='" + $this.min + "' max='" + $this.max + "' step='" + $this.step + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Range){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='range' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' min='" + $this.min + "' max='" + $this.max + "' step='" + $this.step + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Date){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='date' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' min='" + $this.min + "' max='" + $this.max + "' step='" + $this.step + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Month){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='month' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' min='" + $this.min + "' max='" + $this.max + "' step='" + $this.step + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Week){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='week' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' min='" + $this.min + "' max='" + $this.max + "' step='" + $this.step + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::Time){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='time' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' min='" + $this.min + "' max='" + $this.max + "' step='" + $this.step + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + "'></div>"
        }
        elseif($this.formType -eq [RocketFormType]::DateTimeLocal){
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='datetime-local' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' min='" + $this.min + "' max='" + $this.max + "' step='" + $this.step + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + "'></div>"
        }
        else{
            return "<div class='form-group'><label for='" + $this.id + "'>" + $this.label + "</label><input type='color' name='" + $this.name + "' value='" + $this.value + "' placeholder='" + $this.placeholder + "' id='" + $this.id + "' class='" + $this.class + "' style='" + $this.style + "' required='" + $this.required + $( If ($this.disabled) { "disabled" } ) + "'></div>"
        }
    }
}

class RocketForm {
    [string] $action
    [string] $method
    [System.Array] $fields

    RocketForm () {
        $this.action = ""
        $this.method = ""
        $this.fields = @()
    }

    [string] Render () {
        $form = "<form action='" + $this.action + "' method='" + $this.method + "'>"
        foreach ($field in $this.fields) {
            $form += $field.Render()
        }
        $form += "</form>"

        return $form
    }

    [void] Bind ($request){
        $body = $request.InputStream
        $encoding = $request.ContentEncoding
        $reader = [System.IO.StreamReader]::new($body, $encoding)
        $data = $reader.ReadToEnd()
        $dataFields = $data.Split("&")

        foreach ($dataField in $dataFields) {
            $dataFieldSplit = $dataField.Split("=")
            $fieldName = $dataFieldSplit[0]
            $fieldValue = $dataFieldSplit[1]

            $this | Get-Member -MemberType Property | ForEach-Object {
                $propertyName = $_.Name
                if($propertyName.ToUpper() -eq $fieldName.ToUpper()){
                    $this.$propertyName = $fieldValue
                }
            }
        }
    }
}
    