function Get-UnifiSiteRouting {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name,
        [switch]$All
    )
    if ($All){
        $URI = "$controller/api/s/$name/stat/routing"
    }
    else {
        $URI = "$controller/api/s/$name/rest/routing"
    }
    
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List site routing information.

        .DESCRIPTION
        List site routing information. Only user defined routing information is returned by default.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER All
        Switch to include both user defined and default routes.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}