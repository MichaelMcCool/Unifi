function Revoke-UnifiSuperAdmin {
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$ID
    )
    $params = @{
        cmd   = "revoke-super-admin"
        admin = $ID
    }
    $body = New-UnifiCommand $params
    $URI = "$controller/api/s/default/cmd/sitemgr"
    $null = Invoke-POSTRestAPICall -url $URI -payload $body
    <#
        .SYNOPSIS
        Revokes SuperAdmin role for the specified account id.

        .DESCRIPTION
        Revokes SuperAdmin role for the specified account id.
        
        .PARAMETER ID
        Account id. This is listed as _id property from the Get-UnifiAdmin command.

        .INPUTS
        System.String. You can pipe id values into this command.

        .OUTPUTS
        None.
    #>
}