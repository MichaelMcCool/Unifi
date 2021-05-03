
function Get-UnifiSiteSystemInformation {
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name
    ) 
    $URI = "$controller/api/s/$name/stat/sysinfo"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        Lists high-level information about the controller and site.

        .DESCRIPTION
        Lists high-level information about the controller and site.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}
