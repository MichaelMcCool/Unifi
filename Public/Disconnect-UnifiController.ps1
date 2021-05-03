function Disconnect-UnifiController {
    [CmdletBinding()]
    # Disconnect from Unifi controller
    $results = Invoke-Restmethod -Uri "$controller/api/logout" -method post -ContentType "application/json; charset=utf-8" -Websession $session
    if ($results.meta.rc -eq "ok") {
        write-host "Successfully disconnected from Unifi controller."
    }
    <#
        .SYNOPSIS
        Disconnects from the Unifi controller.

        .DESCRIPTION
        Disconnects from the Unifi controller. This will invalidate the current session. This command really isn't needed, 
        but is included for completeness. The API supports a session logout, so this functionality is present in the module.

        .INPUTS
        None.

        .OUTPUTS
        None.    
    #>
}