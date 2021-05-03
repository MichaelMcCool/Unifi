function Connect-UnifiController {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Connect', Mandatory = $true)]$ControllerURL,
        [Parameter(ParameterSetName = 'Connect', Mandatory = $true)][PSCredential]$credentials,
        [Parameter(ParameterSetName = 'Refresh')][switch]$Refresh
    )

    if (!$refresh){
        $script:Controller = $ControllerURL
        $script:Credentials = $credentials
    }
    $params = @{
        username = $script:credentials.GetNetworkCredential().UserName
        password = $script:credentials.GetNetworkCredential().password
    }
    $body = New-UnifiCommand $params
    try {
        $results = Invoke-Restmethod -Uri "$controller/api/login" -method post -body $body -ContentType "application/json; charset=utf-8"  -SessionVariable myWebSession
        if ($results.meta.rc -eq "ok") {
            if (!$refresh){
                write-host "Successfully connected to Unifi controller."
            }
            else {
                Write-Verbose "Successfully connect to Unifi controller."
            }
        }
    }
    catch {
        $APIerror = "API Connection Error: $($_.Exception.Message)"
        $APIerror
        exit 1
    }
    # Set this as a script variable as it will be used for all other commands in the module.
    $Script:Session = $MyWebSession

    <#
        .SYNOPSIS
        Connects to the Unifi controller.

        .DESCRIPTION
        Connects to the Unifi controller. The connection to the Unifi controller will automatically be renewed when the current session expires.

        .NOTES
        Notes and code snippets for building required variables to use with this command:
        
        $Controller="https://<controller IP or DNS Name>:<port>"
        
        $UnifiUsername='<Local Unifi Admin Account>'
        $UnifiPassword='<Password for Local Unifi Admin Account>'
        [SecureString]$SecPassword=ConvertTo-SecureString $UnifiPassword -AsPlainText -Force
        [PSCredential]$Credentials=New-Object System.Management.Automation.PSCredential ($UnifiUsername, $SecPassword)

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