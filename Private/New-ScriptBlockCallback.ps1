
function New-ScriptBlockCallback 
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$Callback
    )

    # Is this type already defined?
    if (-not ( 'CallbackEventBridge' -as [type])) {
        Add-Type @' 
            using System; 

            public sealed class CallbackEventBridge { 
                public event AsyncCallback CallbackComplete = delegate { }; 

                private CallbackEventBridge() {} 

                private void CallbackInternal(IAsyncResult result) { 
                    CallbackComplete(result); 
                } 

                public AsyncCallback Callback { 
                    get { return new AsyncCallback(CallbackInternal); } 
                } 

                public static CallbackEventBridge Create() { 
                    return new CallbackEventBridge(); 
                } 
            } 
'@
    }
    $bridge = [callbackeventbridge]::create()
    Register-ObjectEvent -InputObject $bridge -EventName callbackcomplete -Action $Callback -MessageData $args > $null
    $bridge.Callback
}