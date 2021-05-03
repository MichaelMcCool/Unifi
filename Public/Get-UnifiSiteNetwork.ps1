function Get-UnifiSiteNetwork {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name
    ) 
    $URI = "$controller/api/s/$name/rest/networkconf"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List network configuration.

        .DESCRIPTION
        List network configuration.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}