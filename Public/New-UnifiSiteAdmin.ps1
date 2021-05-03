function New-UnifiSiteAdmin {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Existing")]
        [Parameter(Mandatory=$true, ParameterSetName='SuperAdmin')]
        [Parameter(Mandatory=$true, ParameterSetName='Admin')]
        [Parameter(Mandatory=$true, ParameterSetName='Email')]
        [string]$name,

        [Parameter(Mandatory=$true, ParameterSetName="Existing")]
        [string]$ID,

        [Parameter(Mandatory=$true, ParameterSetName='SuperAdmin')]
        [Parameter(Mandatory=$true, ParameterSetName='Admin')]
        [Parameter(Mandatory=$true, ParameterSetName='Email')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]$Credentials,

        [Parameter(ParameterSetName='SuperAdmin')]
        [Parameter(ParameterSetName='Admin')]
        [switch]$ForcePasswordChange,

        [Parameter(Mandatory=$true, ParameterSetName='SuperAdmin')]
        [Parameter(Mandatory=$true, ParameterSetName='Admin')]
        [Parameter(Mandatory=$true, ParameterSetName='Email')]
        [string]$Email,

        [Parameter(Mandatory=$true, ParameterSetName="Existing")]
        [Parameter(Mandatory=$true, ParameterSetName='Admin')]
        [Parameter(Mandatory=$true, ParameterSetName='Email')]
        [ValidateSet('admin','readonly', IgnoreCase=$false)]
        [string]$Role,

        [Parameter(Mandatory=$true, ParameterSetName='SuperAdmin')]
        [boolean]$SuperAdmin,

        [Parameter(Mandatory=$true, ParameterSetName='Email')]
        [Switch]$EmailInvite,

        [Parameter(ParameterSetName='Email')]
        [switch]$SSO,

        [Parameter(ParameterSetName="Existing")]
        [Parameter(ParameterSetName='Admin')]
        [Parameter(ParameterSetName='Email')]
        [boolean]$AdoptDevices,

        [Parameter(ParameterSetName="Existing")]
        [Parameter(ParameterSetName='Admin')]
        [Parameter(ParameterSetName='Email')]
        [boolean]$PendingDevices,

        [Parameter(ParameterSetName="Existing")]
        [Parameter(ParameterSetName='Admin')]
        [Parameter(ParameterSetName='Email')]
        [boolean]$DashboardEdit,

        [Parameter(ParameterSetName="Existing")]
        [Parameter(ParameterSetName='Admin')]
        [Parameter(ParameterSetName='Email')]
        [boolean]$SystemStats,

        [Parameter(ParameterSetName="Existing")]
        [Parameter(ParameterSetName='Admin')]
        [Parameter(ParameterSetName='Email')]
        [boolean]$GlobalReadOnly
    )
    function GlobalPermissions {
        $Permissions = [System.Collections.ArrayList]@()
        if ($PendingDevices -eq $true){
            [void]$Permissions.add("API_STAT_DEVICE_ACCESS_SUPER_SITE_PENDING")
        }
        if ($DashboardEdit -eq $true){
            [void]$Permissions.add("API_DASHBOARD_EDIT")
        }
        if ($SystemStats -eq $true){
            [void]$Permissions.add("API_WIDGET_OS_STATS")
        }
        if ($GlobalReadOnly -eq $true){
            [void]$Permissions.add("GLOBAL_READONLY_ADMIN_ACCESS")
        }
        $Permissions
    }

    $URI = "$controller/api/s/$name/cmd/sitemgr"
    # Username may only be upper case, lower case, numbers and underscore. Spaces are automatically stripped out as this is
    # the most likely error to be present.
    if ($Credentials){
    [ValidatePattern("^[a-zA-Z0-9_]*$")][string]$Username=($Credentials.GetNetworkCredential().UserName).replace(' ','')
    [string]$Password=$Credentials.GetNetworkCredential().Password
    }


    $GlobalPermissions=GlobalPermissions
    write-verbose $GlobalPermissions.count


    if ($AdoptDevices -eq $true){
        $SitePermissions = @('API_DEVICE_ADOPT')
    }
    else {
        $SitePermissions = @()
    }
    
    
    switch ($PsCmdlet.ParameterSetName){
        {'Admin' -or 'SuperAdmin'} {
            write-verbose "ParameterSet $_ was used."
            # Set ParameterSet specific options.
            if ($ForcePasswordChange){
                $PasswordChange=$true
            }
            else {
                $PasswordChange=$false
            }
            # The administrator role will always be 'readonly' when creating a SuperAdmin.
            if ($SuperAdmin -eq $true){
                $Role = 'readonly'
            }
            #Create Admin
            $Params=@{
                cmd = 'create-admin'
                email = $Email
                name = $Username
                requires_new_password = $PasswordChange
                role = $Role
                x_password = $Password
                permissions = $SitePermissions
            }
            $target=$username
            $command='create-admin'

        }
        'Email' {
            write-verbose "ParameterSet $_ was used."
            if ($SSO){
                $ForSSO = $true
            }
            else {
                $ForSSO = $false
            }

            $Params=@{
                cmd = 'invite-admin'
                email = $Email
                for_sso = $ForSSO
                name = $Username
                role = $Role
                permissions = $SitePermissions
                super_site_permissions = $GlobalPermissions
            }
            $target=$username
            $command='invite-admin'
        }
        'Existing' {
            write-verbose "ParameterSet $_ was used."
            $Params=@{
                cmd = 'grant-admin'
                admin = $ID
                role = $Role
                permissions = $SitePermissions
            }
            $target=$ID
            $command='grant-admin'
        }
        default {
            write-verbose "No ParameterSet used. $_"
        }
    }

    # admin command
    $body = New-UnifiCommand $params
    write-verbose "Command parameters for admin role:"
    write-verbose $body

    if ($PSCmdlet.ShouldProcess($target,$command)){
        $Response=Invoke-POSTRestAPICall -url $URI -payload $body
    }

    #Superadmin command -- The superadmin permissions are already part of the invite-admin command.
    if (($GlobalPermissions.count -ge 1) -AND ($PsCmdlet.ParameterSetName -ne 'Email')){
        if ([string]::IsNullOrEmpty($ID)){
            write-verbose "No admin ID found. Using value from previous controller response."
            $ID=$Response.data._id
        }
        $SuperParams=@{
            cmd = 'grant-super-admin'
            admin = $ID
            role = 'nobody'
            permissions = $GlobalPermissions
        }
        $body = New-UnifiCommand $SuperParams
        write-verbose "Command parameters for superadmin role:"
        write-verbose $body
        if ($PSCmdlet.ShouldProcess($target,'grant-super-admin')){
            $SAResponse=Invoke-POSTRestAPICall -url $URI -payload $body
        }
    }
    
    
    <#
        .SYNOPSIS
        Creates a new site administrator.

        .DESCRIPTION
        Creates a new site administrator. 

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.
        
        .PARAMETER Credentials
        A PSCrendentials object containing the username and password. The password needs to be in plain text.

        .PARAMETER Email
        Email address for the new admin user.

        .PARAMETER Role
        Specify if the new account will be an 'admin' or 'readonly' account.

        .PARAMETER EmailInvite
        Specify that this user should be sent an email invite to manage the site rather than creating the credentials manually.

        .PARAMETER SSO
        Switch to specify that this account will have remote access through a Unifi SSO account. Without this switch, direct access to the controller will be needed.

        .PARAMETER SuperAdmin
        Specify that this account will be a SuperAdmin with access to all sites rather than limited to the site specified.

        .PARAMETER ForcePasswordChange
        Prompts for a new password upon initial logon.

        .PARAMETER AdoptDevices
        Allows for device adoptions.

        .PARAMETER PendingDevices
        Allows for viewing of pending devices.

        .PARAMETER DashboardEdit
        Allows for editing dashboard.

        .PARAMETER SystemStats
        Allows for viewing system statistics.

        .PARAMETER GlobalReadOnly
        Assigns readonly rights for all other sites.


        .INPUTS
        None.

        .OUTPUTS
        System.Object
    #>
}
