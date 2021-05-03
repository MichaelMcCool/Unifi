function Get-UnifiSiteAdmin {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name
    )
    $params = @{
        cmd   = "get-admins"
    }
    $body = New-UnifiCommand $params
    $URI = "$controller/api/s/$name/cmd/sitemgr"
    (Invoke-POSTRestAPICall -url $URI -payload $body).data
    <#
        .SYNOPSIS
        List all administrators and permissions for this site.

        .DESCRIPTION
        List all administrators and permissions for this site.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .INPUTS
        System.String. You can pipe id values into this command.

        .OUTPUTS
        System.Object.
    #>
}