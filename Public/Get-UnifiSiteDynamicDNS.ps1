function Get-UnifiSiteDynamicDNS {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name,
        [switch]$Status
    )
    if ($status){
        $URI = "$controller/api/s/$name/stat/dynamicdns"
    }
    else {
        $URI = "$controller/api/s/$name/rest/dynamicdns"
    }
    
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List Dynamic DNS configuration and optionally status.

        .DESCRIPTION
        List Dynamic DNS configuration and optionally status. Requires a USG.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER Status
        Switch to include Dynamic DNS status as well as configuration. (Current IP, last updated, and status.)
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}