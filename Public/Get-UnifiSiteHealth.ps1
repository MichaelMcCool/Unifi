function Get-UnifiSiteHealth {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$Name,
        [Parameter(Mandatory = $false)][switch]$Raw
    )
    $URI = "$controller/api/s/$name/stat/health"
    
    $Results = (Invoke-GetRestAPICall $URI).data
    if ($Raw) {
        $Results
    }
    else {
        ConvertTo-UnifiObject -Object $Results -Delimiter "subsystem"
    }
    <#
        .SYNOPSIS
        Reports the health status of the specified site.

        .DESCRIPTION
        Reports the health status of the specified site.
        
        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .PARAMETER Raw
        Switch to return the raw health results as received from the API.

        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}