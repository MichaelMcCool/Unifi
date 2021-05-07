# Unifi
This module is designed to provide programmatic access to the various commands and functions in the Unifi controller module via powershell. 
The functions here are based on information from the [Ubiquiti Community Wiki](https://ubntwiki.com/products/software/unifi-controller/api) along with reverse engineering the controller's web UI. 
## Installation instrcutions
    install-module Unifi
## Usage
To get started with using the module and connecting to the controller, you will need an administrator account on the Unifi controller. 
The following code will provide the necessary data and commands to setup the connection:
    
    
    [String]$Hostname = '<FQDN or IP address of the controller>'
    [String]$Port = '8443' # Change this to match the listening port
    [String]$UnifiUsername = '<Unifi controller username>'
    [String]$UnifiPassword = '<Unifi controller password>'
    
    [String]$Controller = "https://$($hostname):$($port)"
    
    # Enables TLS1.2 -- this is a universal method that works for any dot net version
    [Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
    
    # Ignore self-signed certificates 
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    
    # Create a secure credential object
    [securestring]$SecPassword=ConvertTo-SecureString $UnifiPassword -AsPlainText -Force
    [pscredential]$Credentials=New-Object System.Management.Automation.PSCredential ($UnifiUsername, $SecPassword)
    
    import-module Unifi
    
    Connect-UnifiController -ControllerURL $Controller -credentials $Credentials

*Note: After the initial connection, the module will automatically refresh the connection as needed.*

To end the session and disconnect from the controller:

    Disconnect-UnifiController
*Note: it is not necessary to disconnect from the controller specifically as the session will end on its own after a few minutes.*

The command to ignore self-signed certificates will prevent successful communication with other sites. To restore normal functionality, set the value to $null. This is only needed if you want to reuse the current powershell session.

    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null

### Example commands
Retrieve a list of all sites.

    Get-UnifiSite
    
Retrieve a list of all products supported by the controller.

    Get-UnifiProductList
    
    Model    Type ProductName
    -----    ---- -----------
    BZ2      uap  UAP
    BZ2LR    uap  UAP-LR
    U2HSR    uap  UAP-Outdoor+
    U2IW     uap  UAP-IW
    U2L48    uap  UAP-LR
    U2Lv2    uap  UAP-LRv2
    U2M      uap  UAP-Mini
    U2O      uap  UAP-Outdoor
    U2S48    uap  UAP
    U2Sv2    uap  UAPv2
    U5O      uap  UAP-Outdoor5
    U7E      uap  UAP-AC
    U7EDU    uap  UAP-AC-EDU
    U7Ev2    uap  UAP-AC
    ...


Retrieve a list of all administrator accounts

    Get-UnifiAdmin

Retrieve a list of all administrators for a specific site

    Get-UnifiSiteAdmin -name <site name>
    
Retrieve a list of all site devices

    Get-UnifiSiteDevice -name <site name>

Reboot a device

    Set-UnifiSiteDevice -name <site name> -mac <device mac> -restart
    
Force provision a device

    Set-UnifiSiteDevice -name <site name> -mac <device mac> -provision

Upgrade device firmware

    Set-UnifiSiteDevice -name <site name> -mac <device mac> -upgrade
    
Upgrade device firmware with specific firmware

    Set-UnifiSiteDevice -name <site name> -mac <device mac> -upgrade -URL <firmware URL>
    

## Documentation
Documentation for all commands have been included in the comment based help. To see all available information, please use the *-full* switch.

    Get-Help <command> -full
    
List all available commands

    Get-Command -module Unifi

# Contributions
Feel free to send pull requests or submit issues when you encounter them.
### Help needed!
The way the site settings are stored in the controller database, the settings themselves aren't present until they are actually used. I could not determine all possible settings, just the ones that were configured in my environment. I have made a test tool to go through and evaluate all existing sites and their settings and it will list any settings that have not already been accounted for. Please run this tool on your environment and report any new settings it finds. Thanks!

    Test-UnifiSiteKnownSetting

# Future Plans

This initial release covers all the functionality needed in my environment. I do have plans to eventually support the rest of the callable commands listed in the [Ubiquity Community Wiki](https://ubntwiki.com/products/software/unifi-controller/api), although I have no specific ETA. If you have a specific feature request, send me a note!
