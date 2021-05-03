function Get-UnifiSiteFirewallGroup {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)][string]$name,
        [switch]$Known
    )
    $URI = "$controller/api/s/$name/rest/firewallgroup"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List current firewall groups.

        .DESCRIPTION
        List current firewall groups.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}