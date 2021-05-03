function Get-UnifiStatus {
    [CmdletBinding()]
    param()
    $URI = "$controller/status"
    (Invoke-GetRestAPICall $URI).meta
    <#
        .SYNOPSIS
        Basic controller status.

        .DESCRIPTION
        Basic controller status. Data includes request response code, up status, controller version and uuid.
        
        .INPUTS
        None.

        .OUTPUTS
        System.Object.
    #>
}
