function Get-UnifiSiteSetting {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name,
        [switch]$Raw
    )
    $URI = "$controller/api/s/$name/rest/setting"
    $Results = (Invoke-GetRestAPICall $URI).data
    if ($Raw) {
        $Results
    }
    else {
        ConvertTo-UnifiObject -Object $Results -Delimiter "key" -Filter
    }
    <#
        .SYNOPSIS
        Lists settings for a site.

        .DESCRIPTION
        Lists settings for a site. Not all settings will exist for newly created sites. Settings may only be available if the site 
        setting in question has been edited and saved in the web UI first.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER Raw
        Indicates if the command should return the raw REST API data. If this switch is ommited, the data will be returned in a more usable format.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}