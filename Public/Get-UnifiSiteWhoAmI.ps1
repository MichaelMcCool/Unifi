function Get-UnifiSiteWhoAmI {
    param (
        [Parameter(Position=0, Mandatory = $true, ValueFromPipeline = $true)][string]$name
    )
    $URI = "$controller/api/s/$name/self"
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