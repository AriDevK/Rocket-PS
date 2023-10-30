# Description: This file is used to load all the modules and 
#              scripts required to run the application.

using namespace System
using namespace System.Net
using namespace System.Collections
using namespace System.Collections.Generic

Import-Module .\config.ps1 -Verbose
Import-Module eps.ps1 -Verbose
Import-Module .\lib\rocket_form.ps1 -Verbose
Import-Module .\lib\rocket_router.ps1 -Verbose
Import-Module .\lib\rocket_server.ps1 -Verbose
Import-Module .\lib\rocket_gui.ps1 -Verbose

Import-Module .\main.ps1 -Verbose