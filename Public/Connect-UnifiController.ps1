function Connect-UnifiController {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Connect', Mandatory = $true)]$ControllerURL,
        [Parameter(ParameterSetName = 'Connect', Mandatory = $true)][PSCredential]$credentials,
        [Parameter(ParameterSetName = 'Refresh')][switch]$Refresh,
        [Parameter(ParameterSetName = 'Connect')][switch]$UDMPro
    )

    if (!$refresh){

        if ($UDMPro) {
            $script:LoginURI="$ControllerURL/api/auth/login"
            $ControllerURL = $ControllerURL+"/proxy/network"
        }
        else {
            $script:LoginURI="$ControllerURL/api/login"
        }
        $script:Controller = $ControllerURL
        $script:Credentials = $credentials
    }
    
    $params = @{
        username = $script:credentials.GetNetworkCredential().UserName
        password = $script:credentials.GetNetworkCredential().password
    }
    $body = New-UnifiCommand $params
    
    try {
        $results = Invoke-Restmethod -Uri $LoginURI -method post -body $body -ContentType "application/json; charset=utf-8"  -SessionVariable myWebSession
        if ($results.meta.rc -eq "ok") {
            if (!$refresh){
                write-host "Successfully connected to Unifi controller."
            }
            else {
                Write-Verbose "Successfully connect to Unifi controller."
            }
        # Set this as a script variable as it will be used for all other commands in the module.
        $Script:Session = $MyWebSession
        }
    }
    catch {
        $APIerror = "API Connection Error: $($_.Exception.Message)"
        $APIerror
    }
    <#
        .SYNOPSIS
        Connects to the Unifi controller.

        .DESCRIPTION
        Connects to the Unifi controller. If you are connecting to a UDMPro, make sure to use the '-UDMPro' switch. The connection 
        to the Unifi controller will automatically be renewed when the current session expires. 

        .PARAMETER ControllerURL
        Complete URI for the controller. i.e.: https://mycontroller:8443

        .PARAMETER Credentials
        PSCredential object containing the user name and a plaintext secure string for the password.

        .PARAMETER UDMPro
        Switch for connecting to UDMPro devices. The login endpoint and base URL is different for UDMPro devices vs. Unifi controllers.

        .NOTES
        Notes and code snippets for building required variables to use with this command:
        
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

        .INPUTS
        None.

        .OUTPUTS
        None.    

        .EXAMPLE
        Connect-UnifiController -ControllerURL $Controller -credentials $Credentials
        
        Connects to the Unifi controller URI specified in the $controller variable and uses the credentials provided in the $Credentials variable.
        $Controller is the full URI and port required for accessing the controller's web UI. The $Credentials variable is a PSCredential object.
        Please see notes for more information about how to create these variables.
    #>
}