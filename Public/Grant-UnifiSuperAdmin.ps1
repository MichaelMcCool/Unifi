
function Grant-UnifiSuperAdmin {
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$ID
    )
    $params = @{
        cmd   = "grant-super-admin"
        admin = $ID
    }
    $body = New-UnifiCommand $params
    $URI = "$controller/api/s/default/cmd/sitemgr"
    $null = Invoke-POSTRestAPICall -url $URI -payload $body
    <#
        .SYNOPSIS
        Grants SuperAdmin role for the specified account id.

        .DESCRIPTION
        Grants SuperAdmin role for the specified account id.
        
        .PARAMETER ID
        Account id. This is listed as _id property from the Get-UnifiAdmin command.

        .NOTES
        The grant-super-admin command will only function on accounts that show the property 'is_verified' as 'true'.

        .INPUTS
        System.String. You can pipe id values into this command.

        .OUTPUTS
        None.
    #>
}