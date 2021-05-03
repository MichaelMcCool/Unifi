function Set-UnifiSiteSetting {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position=0, Mandatory = $true)][string]$name,
        [ValidateSet(
            "auto_speedtest",
            "connectivity",
            "country",
            "dpi",
            "element_adopt",
            "guest_access",
            "ips",
            "lcm",
            "locale",
            "mgmt",
            "network_optimization",
            "ntp",
            "porta",
            "provider_capabilities",
            "radio_ai",
            "radius",
            "rsyslogd",
            "snmp",
            "super_cloudaccess",
            "super_events",
            "super_identity",
            "super_mail",
            "super_mgmt",
            "super_sdn",
            "super_smtp",
            "usg",
            "usw"
        )]
        [Parameter(Position=1, Mandatory = $true)][string]$Setting,
        [Parameter(Position=2, Mandatory = $true)]$Object
    )
    # Converts hash tables to objects.
    if (($object.gettype()).name -ne "PSCustomObject"){
        $object=ConvertTo-Object $object
    }
    # validate the setting defined actually exists.
    $SiteSpecificSettings=Get-UnifiSiteSetting $name
    $Props = ($SiteSpecificSettings | get-member -membertype NoteProperty).Name
    write-verbose "Available settings: $props"
    if ($props -notcontains $Setting){
        Throw "Setting `"$Setting`" not found. Valid options are: $props."
    }
    # Now since this is a valid section, grab the settings for this section.
    $SectionOptions=$SiteSpecificSettings.$Setting
    write-verbose "Original $setting settings: $($SiteSpecificSettings.$Setting)"
    $SectionProps=($SectionOptions | get-member -membertype NoteProperty).name
    foreach ($item in $object){
        $ItemName=($item | get-member -MemberType NoteProperty).name
        if ($SectionProps -notcontains  $ItemName) {
            Throw "Property $ItemName not valid for $setting setting."
        }
        else {
            write-verbose "Found property $itemname with value of $($item.$itemname)"
            $SiteSpecificSettings.$setting.$ItemName=$item.$itemname
        }
    }
    
    write-verbose "Updated $setting settings: $($SiteSpecificSettings.$Setting)"
    $URI="$controller/api/s/$name/set/setting/$setting/$($SiteSpecificSettings.$setting._id)"
    $body=New-UnifiCommand $SiteSpecificSettings.$Setting
    write-verbose "Command URI: $URI"
    write-verbose "Payload: $body"
    if ($PSCmdlet.ShouldProcess($URI,"Invoke-PostRestAPICall")){
        (Invoke-POSTRestAPICall -url $URI -payload $body).meta.rc
    }
    
    <#
        .SYNOPSIS
        Configures site settings.

        .DESCRIPTION
        Configures site settings. The method for generating the setting _id value is not known, so it is not possible to modify a setting 
        that doesn't already exist when running the Get-UnifiSiteSetting command. Many site settings do not exist in the API until they 
        have been saved at least once via the Web UI.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER Setting
        The site setting section to update. Valid options are auto_speedtest, connectivity, country, dpi, element_adopt, guest_access, ips, 
        lcm, locale, mgmt, network_optimization, ntp, porta, provider_capabilities, radio_ai, radius, rsyslogd, snmp, super_cloudaccess, 
        super_events, super_identity, super_mail, super_mgmt, super_sdn, super_smtp, usg, and usw. These are further limited to only settings
        that currently exist when running the Get-UnifiSiteSetting command for the specified site.

        To check for currently unsupported options, please run the Test-UnifiSiteKnownSetting command. If this test script finds any additional values,
        please inform the module author so these can be added.

        .PARAMETER Object
        This is an object containing the key/value pairs for any updated settings. Only updated values need to be included. The updated values
        will be merged with the existing values. Including key/value pairs which do not exist in the current settings will generate an error.

        .INPUTS
        None.
        
        .OUTPUTS
        System.String - This is the response status value from the Unifi controller. It should report 'ok' unless there is an error with the update process.

        .EXAMPLE
        Set-UnifiSiteSetting -name 'default' -setting 'locale' -object @{timezone='America/Chicago'} -confirm

        Changes the timezone parameter for the locale settings to 'America/Chicago with a confirmation prompt before executing the update.

        .EXAMPLE
        $Params=@{timezone = 'UTC'}; Set-UnifiSiteSetting -Name 'default' -Setting 'locale' -Object $Params -WhatIf -Verbose

        Uses -WhatIf switch to test changing the timezone parameter for the local setting to 'UTC'. The -Verbose switch is used to output various 
        other bits of data from the function to confirm that it is executing as expected before actually making the change to the controller.

        VERBOSE: GET <controller URI>/api/s/<site name>/rest/setting with 0-byte payload
        VERBOSE: received -1-byte response of content type application/json;charset=UTF-8
        VERBOSE: Available settings: auto_speedtest connectivity country dpi element_adopt guest_access lcm locale mgmt network_optimization 
        ntp provider_capabilities rsyslogd super_cloudaccess super_events super_identity super_mail super_mgmt super_sdn super_smtp usg usw
        VERBOSE: Original locale settings: @{key=locale; site_id=<site id>; timezone=America/Chicago; _id=<_id>}
        VERBOSE: Found property timezone with value of UTC
        VERBOSE: Updated locale settings: @{key=locale; site_id=<site id>; timezone=UTC; _id=<_id>}
        VERBOSE: Command URI: <controller URI>/api/s/<site name>/set/setting/locale/<_id>
        VERBOSE: Payload: {
            "key":  "locale",
            "site_id":  "<site id>",
            "timezone":  "UTC",
            "_id":  "<_id>""
        }
        What if: Performing the operation "Invoke-PostRestAPICall" on target "<controller URI>/api/s/<site name>/set/setting/locale/<_id>".

        .NOTES
        While this function has been designed to be as robust as possible, it is not possible to validate the property values provided to the command. When updating
        the controller, it will gladly accept any value provided, including invalid options. Please make sure you have a good backup of your controller data
        before making changes. 
        
        Do not under any circumstances change the _id or site_id key/value pairs.

        Any update to the site settings will force all devices to reprovision. This cannot be disabled.
    #>    
}