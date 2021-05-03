function Get-UnifiSiteWarning {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name
    )
        $URI = "$controller/api/s/$name/stat/widget/warnings"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List site warnings.

        .DESCRIPTION
        List site warnings.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}