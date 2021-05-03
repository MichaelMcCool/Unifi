function Get-UnifiSiteCountryCode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)][string]$name = 'default'
    )
    $URI = "$controller/api/s/$name/stat/ccode"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List all country code information.

        .DESCRIPTION
        List all country code information.

        .NOTES
        The country code information does not appear to change for any site queried. However, the API lists this
        as site level information, so that it why this is a site level command. If not supplied a specific site to 
        query, it will use the value of 'default'.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}