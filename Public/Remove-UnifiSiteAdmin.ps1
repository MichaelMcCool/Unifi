function Remove-UnifiSiteAdmin {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName='Default')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName='Others')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName='All')]
        [string]$name,
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName='Default')]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName='Others')]
        [Parameter(Position = 1, Mandatory = $false, ParameterSetName='All')]
        [string]$ID,
        [Parameter(Mandatory = $true, ParameterSetName='Others')][Switch]$Others,
        [Parameter(Mandatory = $true, ParameterSetName='All')][Switch]$All,
        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Others')]
        [Parameter(ParameterSetName='All')][switch]$Force
    )
    # Make sure the specified ID actually exists.
    write-verbose "Looking up admin account information for admin $id."
    #$AccountInfo=get-unifiadmin | where-object {$_._id -eq $ID}
    $AccountInfo=Get-UnifiSiteAdmin -name $name | where-object {$_._id -eq $ID}
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
        if ($all){
            $AccountInfo=get-unifiadmin | where-object {$_._id -eq $ID}
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
            $ResponseDetails
        }
        if ($Others){
            $AccountInfo=get-unifiadmin | where-object {$_._id -eq $ID}
            $ResponseDetails = [System.Collections.Generic.List[psobject]]::new()
            $params = @{
                cmd   = "revoke-admin"
                admin = $ID
            }
            $body = New-UnifiCommand $params
            foreach ($site in ($AccountInfo.roles | sort-object -property "site_desc")){
                if ($site.site_name -eq $name){
                    $ResponseDetails.Add(
                        [PSCustomObject]@{
                            AccountID = $ID
                            AccountName = $AccountInfo.name
                            SiteName = $site.site_name
                            SiteDescription = $site.site_desc
                            Results = "skipped"
                        }
                    )
                }
                else {
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
                

            }
            $ResponseDetails
        }
        if (!$All -or !$Others){
            $ResponseDetails = [System.Collections.Generic.List[psobject]]::new()
            $params = @{
                cmd   = "revoke-admin"
                admin = $ID
            }
            $body = New-UnifiCommand $params
            $URI = "$controller/api/s/$name/cmd/sitemgr"
            $site=Get-UnifiSite | where-object {$_.name -eq $name}
            write-verbose "Removing account $($AccountInfo.name) from $($site.desc)."
                $Response=Invoke-POSTRestAPICall -url $URI -payload $body
                $ResponseDetails.Add(
                    [PSCustomObject]@{
                        AccountID = $ID
                        AccountName = $AccountInfo.name
                        SiteName = $site.name
                        SiteDescription = $site.desc
                        Results = $Response.meta.rc
                    }
                )
            }
            $ResponseDetails
        }

    #Remove superadmin role if 
    # $params = @{
    #     cmd   = "revoke-super-admin"
    #     admin = $ID
    # }
    # $body = New-UnifiCommand $params
    # $URI = "$controller/api/s/default/cmd/sitemgr"

    # $null = Invoke-POSTRestAPICall -url $URI -payload $body
    <#
        .SYNOPSIS
        Remove the administrator account specified.

        .DESCRIPTION
        Remove the administrator account specified. Optionally, can remove it from all sites, or only other sites. 
        When switch -all or -others are specified, output will contain a object with site specific of response details.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .PARAMETER ID
        Account id. This is listed as _id property from the Get-UnifiSiteAdmin command. 

        .PARAMETER Others
        Remove the administrator account from all other sites except the one specified. When this command is specified, output will contain a object with site specific of response details.

        .PARAMETER All
        Remove the administrator account from all sites. When this command is specified, output will contain a object with site specific of response details.

        .INPUTS
        None.

        .OUTPUTS
        System.Object
    #>
}