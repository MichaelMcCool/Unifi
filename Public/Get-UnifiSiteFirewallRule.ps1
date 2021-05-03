function Get-UnifiSiteFirewallRule {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)][string]$name,
        [switch]$Known
    )
    $URI = "$controller/api/s/$name/rest/firewallrule"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List user defined firewall rules.

        .DESCRIPTION
        List user defined firewall rules. Auto-generated rules will not be listed.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}