function Get-UnifiSiteKnownAccessPoint {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$Name,
        [Parameter(Position = 1, Mandatory = $false)][int]$Hours
    )
    $URI = "$controller/api/s/$name/stat/rogueap"
    if ($Hours){
        $params = @{
            within = $Hours
        }
        $body = New-UnifiCommand $params
        (Invoke-POSTRestAPICall -url $URI -payload $body).data
    }
    else {
        (Invoke-GetRestAPICall $URI).data
    }
    
    <#
        .SYNOPSIS
        List known access points.

        .DESCRIPTION
        List known access points. These are all neighboring access points seen by connected APs.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER Hours
        Limit known access point results to the last X hours.

        .EXAMPLE
        Get-UnifiSiteKnownAccessPoint -Name default -Hours 24

        Returns a list of all neighboring access points seen in the last 24 hours for the default site.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}