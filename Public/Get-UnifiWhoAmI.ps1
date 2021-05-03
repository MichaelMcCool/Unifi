function Get-UnifiWhoAmI {
    param ()
    $URI = "$controller/api/self"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        Returns information about the logged in user.

        .DESCRIPTION
        Returns information about the logged in user.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}