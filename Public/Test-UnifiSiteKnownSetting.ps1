function Test-UnifiSiteKnownSetting {
    [CmdletBinding()]
    param()
    $SettingList=@(
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
    )
    $UnifiSites=Get-UnifiSite | sort-object -property desc
    $SettingNames=[System.Collections.ArrayList]@()
    write-host "Building list of Unifi site settings..."
    foreach ($site in $UnifiSites){
        $UnifiSettings=Get-UnifiSiteSetting -name $site.name
        write-host "`tProcessing $($site.desc)..."
        ($UnifiSettings| get-member -MemberType NoteProperty | select-object name) | foreach-object {[void]$settingNames.add($_.name)}
    }
    $UniqueSettings=$SettingNames | sort-object -Unique
    $NewSettings=$false
    foreach ($Setting in $UniqueSettings){
        if ($settinglist -notcontains $setting){
            write-host "Found new site setting: "-nonewline -ForegroundColor Yellow
            write-host "$setting" -NoNewline -ForegroundColor Green
            write-host ". Please inform module maintainer." -ForegroundColor Yellow
            $NewSettings=$true
        }
    }
    if ($NewSettings -eq $false){
        write-host "No new site settings found. No further action necessary."
    }

    <#
        .SYNOPSIS
        Runs diagnostic test to determine if any unknown site settings exist.

        .DESCRIPTION
        Runs diagnostic test to determine if any unknown site settings exist. The list of possible settings are embedded in various modules to 
        assist with tab auto-completion. Settings do not exist until they have been configured at least once through the Unifi WebUI as the 
        method to generate the setting ID value is unknown. This makes it difficult to precisely know all possible settings available. If any
        previously known site settings exist, they will displayed at the end of the script output.
        
        .INPUTS
        None

        .OUTPUTS
        Diagnostic text.
    #>
}
