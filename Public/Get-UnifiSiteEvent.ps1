function Get-UnifiSiteEvent {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name,
        [switch]$IncludeArchived
    )
    If ($IncludeArchived){
        $URI = "$controller/api/s/$name/stat/event"
    }
    else {
        $URI = "$controller/api/s/$name/stat/event?archived=false"
    }
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List site events by most recent first, 3000 result limit.

        .DESCRIPTION
        List site events by most recent first, 3000 result limit. 

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER IncludeArchived
        Switch to return all events, including archived.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>  
}