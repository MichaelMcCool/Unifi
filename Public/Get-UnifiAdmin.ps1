
function Get-UnifiAdmin {
    [CmdletBinding()]
    param ()
    $URI = "$controller/api/stat/admin"
    (Invoke-GetRestAPICall $URI).data
    <#
        .SYNOPSIS
        List all administrators and permissions.

        .DESCRIPTION
        List all administrators and permissions.

        .INPUTS
        None.

        .OUTPUTS
        System.Object.
    #>
}