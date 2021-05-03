function Get-UnifiSiteRadiusProfile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name
    ) 
    $URI = "$controller/api/s/$name/rest/radiusprofile"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List profiles for RADIUS.

        .DESCRIPTION
        List profiles for RADIUS.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}