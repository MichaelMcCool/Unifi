# {"cmd":"update-admin","admin":"6047ea436f6bb00c641fe5c2","name":"TestAdmin7","email":"mmccool7@tmgit.com","email_alert_enabled":false,"email_alert_grouping_enabled":false,"email_alert_grouping_delay":60,"push_alert_enabled":true}
# {"cmd":"set-admin-permissions","admin":"6047ea436f6bb00c641fe5c2","permissions":["API_DEVICE_ADOPT"]}
# {"cmd":"grant-super-admin","admin":"6047ea436f6bb00c641fe5c2","role":"nobody","permissions":["API_STAT_DEVICE_ACCESS_SUPER_SITE_PENDING","API_WIDGET_OS_STATS","API_DASHBOARD_EDIT","GLOBAL_READONLY_ADMIN_ACCESS"]}


#{"cmd":"update-admin","admin":"6047ea436f6bb00c641fe5c2","name":"TestAdmin99","x_password":"kljlkjekrjklejfi9oj39nfnvlnkljfdf","email":"mmccool99@tmgit.com","email_alert_enabled":false,"email_alert_grouping_enabled":false,"email_alert_grouping_delay":60,"push_alert_enabled":false}
function Set-UnifiSiteAdmin {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
            [string]$name, # site name
        [Parameter(Mandatory=$true)]
            [string]$ID, #acount id
        [string]$Username,
        [securestring]$Password,
        [string]$Email,
        [ValidateSet('admin','readonly', IgnoreCase=$false)]
            [string]$Role,
        [boolean]$EmailAlert,
        [boolean]$AlertGrouping,
        [int]$GroupingDelay,
        [boolean]$PushAlert,
        [boolean]$SuperAdmin,
        [boolean]$AdoptDevices,
        [boolean]$PendingDevices,
        [boolean]$DashboardEdit,
        [boolean]$SystemStats,
        [boolean]$GlobalReadOnly
    )
    # @{cmd ="update-admin"
    # admin = $ID
    # name = $Username
    # email = $email
    # email_alert_enabled = $EmailAlert
    # email_alert_grouping_enabled = $AlertGrouping
    # email_alert_grouping_delay = $GroupingDelay
    # push_alert_enabled = ""
    # }
    $URI = "$controller/api/s/$name/cmd/sitemgr"
    write-verbose $PSBoundParameters.Keys
    $admin = Get-UnifiSiteAdmin -name $name | where-object {$_._id -eq $ID}
    if ($null -eq $admin){
        write-error "Specified ID not found."
    }
    write-verbose $admin
    if ($PSBoundParameters.ContainsKey('Username')){
        $Admin.name = $Username
    }
    if ($PSBoundParameters.ContainsKey('Email')){
        $Admin.email = $Email
    }
    if ($PSBoundParameters.ContainsKey('Role')){
        $Admin.role = $Role
    }
    if ($PSBoundParameters.ContainsKey('EmailAlert')){
        $Admin.email_alert_enabled = $EmailAlert
    }
    if ($PSBoundParameters.ContainsKey('AlertGrouping')){
        $Admin.email_alert_grouping_enabled = $AlertGrouping
    }
    if ($PSBoundParameters.ContainsKey('GroupingDelay')){
        $Admin.email_alert_grouping_delay = $GroupingDelay
    }
    if ($PSBoundParameters.ContainsKey('PushAlert')){
        $Admin.push_alert_enabled = $PushAlert
    }

    #{"cmd":"update-admin",
    # "admin":"6047ea436f6bb00c641fe5c2",
    # "name":"TestAdmin7",
    # "email":"mmccool7@tmgit.com",
    # "email_alert_enabled":false,
    # "email_alert_grouping_enabled":false,
    # "email_alert_grouping_delay":60,
    # "push_alert_enabled":true}
    
    #Update Admin
    $UpdateAdmin=@{
        cmd = 'update-admin'
        admin = $admin._id
        name = $admin.name
        email = $admin.email
        email_alert_enabled = $admin.email_alert_enabled
        email_alert_grouping_enabled = $admin.email_alert_grouping_enabled
        email_alert_grouping_delay = $admin.email_alert_grouping_delay
        push_alert_enabled = $admin.push_alert_enabled
    }
    if ($PSBoundParameters.ContainsKey('Password')){
        #Creating a dummy PSCredentials object just so we can safely use the password securestring.
        [pscredential]$DummyCredential=New-Object System.Management.Automation.PSCredential ('Dummy', $Password)
        $UpdateAdmin | Add-Member -MemberType NoteProperty -Name 'x_password' -Value $DummyCredential.GetNetworkCredential().password
    }

    # Update Admin command
    $body = New-UnifiCommand $UpdateAdmin
    write-verbose $body
    if ($PSCmdlet.ShouldProcess($admin.name,'update-admin')){
        $UpdateResponse=Invoke-POSTRestAPICall -url $URI -payload $body
    }

    #{"cmd":"update-admin",
    # "admin":"6047ea436f6bb00c641fe5c2",
    # "name":"TestAdmin99",
    # "x_password":"kljlkjekrjklejfi9oj39nfnvlnkljfdf",
    # "email":"mmccool99@tmgit.com",
    # "email_alert_enabled":false,
    # "email_alert_grouping_enabled":false,
    # "email_alert_grouping_delay":60,
    # "push_alert_enabled":false}
    


    # Create arraylist of current permissions
    $SitePermissions= new-object system.collections.arraylist($null)
    if ($null -ne $admin.permissions){
        $SitePermissions.addRange($admin.permissions)
    }
    # if specified, update the permissions list.
    if ($PSBoundParameters.ContainsKey('AdoptDevices')){
        if (($AdoptDevices -eq $true) -AND ($SitePermissions -notcontains "API_DEVICE_ADOPT")){
            [void]$SitePermissions.add("API_DEVICE_ADOPT")
        }
        if ($AdoptDevices -eq $false){
            [void]$SitePermissions.Remove("API_DEVICE_ADOPT")
        }
    }
    #{"cmd":"set-admin-permissions","admin":"6047ea436f6bb00c641fe5c2","permissions":["API_DEVICE_ADOPT"]}
    # Create the command to send to the unifi controller.
    if ($admin.is_super -eq $false){
        $SetAdminPermissions=@{
            cmd = 'set-admin-permissions'
            admin = $admin._id
            permissions = $SitePermissions.ToArray()
        }
        $body = New-UnifiCommand $SetAdminPermissions
        write-verbose $body
        if ($PSCmdlet.ShouldProcess($admin.name,'set-admin-permissions')){
            $AdminPermissionsResponse=Invoke-POSTRestAPICall -url $URI -payload $body
        }

        # Add any missing value needed in order to set the super admin permissions.
        if (($admin | get-member -type "NoteProperty").name -notcontains "super_site_role"){
            $admin | Add-Member -MemberType NoteProperty -name "super_site_role" -value "nobody"
        }
    }
    # Now work on the superadmin permissions

    # Create arraylist of current permissions
    $SuperPermissions= new-object system.collections.arraylist($null)
    if ($null -ne $admin.super_site_permissions){
        $SuperPermissions.addRange($admin.super_site_permissions)
    }
    # if specified, update the permissions list.
    if ($PSBoundParameters.ContainsKey('PendingDevices')){
        $key='API_STAT_DEVICE_ACCESS_SUPER_SITE_PENDING'
        if (($PendingDevices -eq $true) -AND ($SuperPermissions -notcontains $key)){
            [void]$SuperPermissions.add($key)
        }
        if ($PendingDevices -eq $false){
            [void]$SuperPermissions.Remove($key)
        }
    }
    if ($PSBoundParameters.ContainsKey('DashboardEdit')){
        $key='API_DASHBOARD_EDIT'
        if (($DashboardEdit -eq $true) -AND ($SuperPermissions -notcontains $key)){
            [void]$SuperPermissions.add($key)
        }
        if ($DashboardEdit -eq $false){
            [void]$SuperPermissions.Remove($key)
        }
    }
    if ($PSBoundParameters.ContainsKey('SystemStats')){
        $key='API_WIDGET_OS_STATS'
        if (($SystemStats -eq $true) -AND ($SuperPermissions -notcontains $key)){
            [void]$SuperPermissions.add($key)
        }
        if ($SystemStats -eq $false){
            [void]$SuperPermissions.Remove($key)
        }
    }
    if ($PSBoundParameters.ContainsKey('GlobalReadOnly')){
        $key='GLOBAL_READONLY_ADMIN_ACCESS'
        if (($GlobalReadOnly -eq $true) -AND ($SuperPermissions -notcontains $key)){
            [void]$SuperPermissions.add($key)
        }
        if ($GlobalReadOnly -eq $false){
            [void]$SuperPermissions.Remove($key)
        }
    }
    if ($PSBoundParameters.ContainsKey('SuperAdmin')){
        if ($SuperAdmin -eq $true){
            # $admin.super_site_role = 'admin'
            # $SuperPermissions=new-object system.collections.arraylist($null)
            Grant-UnifiSuperAdmin -ID $admin._id
            $admin.is_super=$true
        }
        if ($SuperAdmin -eq $false){
            Revoke-UnifiSuperAdmin -ID $admin._id
            $admin.super_site_role = 'nobody'
            $admin.is_super=$false
        }
    }
    if ($admin.is_super -eq $false){
        $SetSuperAdminPermissions=@{
            cmd = 'grant-super-admin'
            admin = $admin._id
            role = $admin.super_site_role
            permissions = $SuperPermissions.ToArray()
        }
        $body = New-UnifiCommand $SetSuperAdminPermissions
        write-verbose $body
        if ($PSCmdlet.ShouldProcess($admin.name,'grant-super-admin')){
            $UpdateSAPermissionsResponse=Invoke-POSTRestAPICall -url $URI -payload $body
        }
    }

        # {"cmd":"grant-super-admin",
    # "admin":"6047ea436f6bb00c641fe5c2",
    # "role":"nobody",
    # "permissions":[
    #     "API_STAT_DEVICE_ACCESS_SUPER_SITE_PENDING",
    #     "API_WIDGET_OS_STATS",
    #     "API_DASHBOARD_EDIT",
    #     "GLOBAL_READONLY_ADMIN_ACCESS"]}




        <#
        .SYNOPSIS
        Updates settings for a site administrator.

        .DESCRIPTION
        Updates settings for a site administrator. This command will update any supplied settings for the specified administrator.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER ID
        Unique id value for the administrator account. This value is listed as _id value in the Get-UnifiSiteAdmin command.

        .PARAMETER Username
        Name for the specified admin.

        .PARAMETER Password
        SecureString value for a new password for the specified account. This is for local accounts only.

        .PARAMETER Email
        Email address for the admin user.

        .PARAMETER Role
        Specify if the account will be an 'admin' or 'readonly' account.

        .PARAMETER EmailInvite
        Switch to specify that this user should be sent an email invite to manage the site rather than creating the credentials manually.

        .PARAMETER SSO
        Switch to specify that this account will have remote access through a Unifi SSO account. Without this switch, direct access to the controller will be needed.

        .PARAMETER SuperAdmin
        Switch to specify that this account will be a SuperAdmin with access to all sites rather than limited to the site specified.

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