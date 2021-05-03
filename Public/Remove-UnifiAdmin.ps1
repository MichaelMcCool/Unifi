function Remove-UnifiAdmin {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Position = 1, Mandatory = $true)][string]$ID,
        [switch]$force
    )
    # Make sure the specified ID actually exists.
    write-verbose "Looking up admin account information for admin $id."
    $AccountInfo=get-unifiadmin | where-object {$_._id -eq $ID}
    if ($null -eq $AccountInfo){
        Write-Error -Message "Specified account id not found." -ErrorAction Stop
    }
    else {
        write-verbose "Found account for admin user $($AccountInfo.name)."
    }
    if ($AccountInfo.is_super -eq $true) {
        if (!$force){
            write-error "Specified account is a super-admin. Aborting removal. Use '-force' to remove super-admin accounts." -ErrorAction Stop
        }
    }
    if ($force){
        $ConfirmPreference='None'
    }
    if ($confirm){
        $ConfirmPreference='High'
    }
    if ($PSCmdlet.ShouldProcess($AccountInfo.name,"Remove-UnifiSiteAdmin")){
        if ($AccountInfo.is_super -eq $true){
            write-verbose "Revoking super_admin privileges."
            Revoke-UnifiSuperAdmin -ID $ID
        }
        $ResponseDetails = [System.Collections.Generic.List[psobject]]::new()
            $params = @{
                cmd   = "revoke-admin"
                admin = $ID
            }
        $body = New-UnifiCommand $params
        foreach ($site in ($AccountInfo.roles | sort-object -property "site_desc")){
            $URI = "$controller/api/s/$($site.site_name)/cmd/sitemgr"
            write-verbose "Removing account $($AccountInfo.name) from $($site.site_desc)."
            $Response=Invoke-POSTRestAPICall -url $URI -payload $body
            $ResponseDetails.Add(
                [PSCustomObject]@{
                    AccountID = $ID
                    AccountName = $AccountInfo.name
                    SiteName = $site.site_name
                    SiteDescription = $site.site_desc
                    Results = $Response.meta.rc
                }
            )

        }
        # Refresh the account information.
        $AccountInfo=get-unifiadmin | where-object {$_._id -eq $ID}
        if ($null -ne $AccountInfo){
            if ($accountinfo.roles.count -eq 0){
                $ResponseDetails
                Write-Error "Ghost account detected. Please assign SuperAdmin rights to this account, then attempt removal again." -ErrorAction Stop
            }
            else {
                $ResponseDetails
                Write-Error "Some site permissions still exist for this account." -ErrorAction Continue
            }
        }
        else {
            $ResponseDetails
        }
    }
    <#
        .SYNOPSIS
        Remove the administrator account specified.

        .DESCRIPTION
        Remove the administrator account specified. This will automatically remove the account from any assigned sites. Output will 
        contain a object with site specific of response details. Use '-force' to remove accounts which have the SuperAdmin role.

        .PARAMETER ID
        Account id. This is listed as _id property from the Get-UnifiAdmin command. 

        .PARAMETER Force
        Force removal of SuperAdmin accounts.

        .NOTES
        On occasion, it is possible to have an admin account assigned to no sites. If this happens, granting the SuperAdmin role to the account
        and removing the account again should fix it.

        .INPUTS
        None.

        .OUTPUTS
        System.Object
    #>
}