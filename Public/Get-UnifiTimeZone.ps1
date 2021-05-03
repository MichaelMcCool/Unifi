function Get-UnifiTimeZone {
    $URI = "$controller/v2/api/timezones"
    (Invoke-GetRestAPICall $URI)
    <#
        .SYNOPSIS
        Returns information about the supported timezones.

        .DESCRIPTION
        Returns information about the supported timezones.
        
        .INPUTS
        None.

        .OUTPUTS
        System.Object.
    #>
}