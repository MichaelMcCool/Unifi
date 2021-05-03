function Get-UnifiSiteClient {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)][string]$name,
        [switch]$Known
    )
    if ($Known){
        $URI = "$controller/api/s/$name/rest/user" 
    }
    else {
        $URI = "$controller/api/s/$name/stat/sta"
    }
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List current devices attached to the network.

        .DESCRIPTION
        List current devices attached to the network. Use the -Known switch to return a list of all known devices. (This list can be quite long.)

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER Known
        Switch to retrieve a list of all known devices. (This list can be quite long.)
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}