function Get-UnifiSiteTag {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name
    )
        $URI = "$controller/api/s/$name/rest/tag"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List tagged MACs.

        .DESCRIPTION
        List tagged MACs.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}