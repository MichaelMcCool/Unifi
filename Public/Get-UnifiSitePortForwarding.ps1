function Get-UnifiSitePortForwarding {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)][string]$name,
        [switch]$Known
    )
    $URI = "$controller/api/s/$name/rest/portforward"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List configured port forwards.

        .DESCRIPTION
        List configured port forwards.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}