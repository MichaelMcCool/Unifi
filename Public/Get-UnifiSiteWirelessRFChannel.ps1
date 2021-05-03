function Get-UnifiSiteWirelessRFChannel {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)][string]$name
    )
    $URI = "$controller/api/s/$name/stat/current-channel"

    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List of all RF channels based on the site's country code.

        .DESCRIPTION
        List of all RF channels based on the site's country code.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}