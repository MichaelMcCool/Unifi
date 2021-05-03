
function Get-UnifiSiteSwitchProfile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name
    ) 
    $URI = "$controller/api/s/$name/rest/portconf"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List profiles for switch ports.

        .DESCRIPTION
        List profiles for switch ports.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}