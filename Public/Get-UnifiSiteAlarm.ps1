
function Get-UnifiSiteAlarm {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name,
        [switch]$IncludeArchived
    )
    if ($IncludeArchived){
        $URI = "$controller/api/s/$name/stat/alarm"
    }
    else {
        $URI = "$controller/api/s/$name/stat/alarm?archived=false"
    }
    

    $Results = (Invoke-GetRestAPICall $URI).data

    # Each device type has its own set of name/model/displayname properties. Add in a generic "device" identifier for ease of use.
    foreach ($Result in $Results){
        switch ($Result.key) {
            {$_ -match "EVT_AP"} {
                # Access Point
                $Result | add-member -memberType AliasProperty -name device -value ap
                $Result | add-member -memberType AliasProperty -name device_name -value ap_name
                $Result | add-member -memberType AliasProperty -name device_model -value ap_model
                $Result | add-member -memberType AliasProperty -name device_displayName -value ap_displayName
            }
            {$_ -match "EVT_DM"} {
                # Dream Machine
                $Result | add-member -memberType AliasProperty -name device -value dm
                $Result | add-member -memberType AliasProperty -name device_name -value dm_name
                $Result | add-member -memberType AliasProperty -name device_model -value dm_model
                $Result | add-member -memberType AliasProperty -name device_displayName -value dm_displayName
            }
            {$_ -match "EVT_GW"} {
                # Gateway
                $Result | add-member -memberType AliasProperty -name device -value gw
                $Result | add-member -memberType AliasProperty -name device_name -value gw_name
                $Result | add-member -memberType AliasProperty -name device_model -value gw_model
                $Result | add-member -memberType AliasProperty -name device_displayName -value gw_displayName
            }
            {$_ -match "EVT_ULTE"} {
                # LTE
                $Result | add-member -memberType AliasProperty -name device -value ulte
                $Result | add-member -memberType AliasProperty -name device_name -value ulte_name
                $Result | add-member -memberType AliasProperty -name device_model -value ulte_model
                $Result | add-member -memberType AliasProperty -name device_displayName -value ulte_displayName
            }
            {$_ -match "EVT_USP_RPS"} {
                # RPS
                $Result | add-member -memberType AliasProperty -name device -value usp_rps
                $Result | add-member -memberType AliasProperty -name device_name -value usp_rps_name
                $Result | add-member -memberType AliasProperty -name device_model -value usp_rps_model
                $Result | add-member -memberType AliasProperty -name device_displayName -value usp_rps_displayName
            }
            {$_ -match "EVT_SW"} {
                # Switch
                $Result | add-member -memberType AliasProperty -name device -value sw
                $Result | add-member -memberType AliasProperty -name device_name -value sw_name
                $Result | add-member -memberType AliasProperty -name device_model -value sw_model
                $Result | add-member -memberType AliasProperty -name device_displayName -value sw_displayName
            }
            {$_ -match "EVT_XG"} {
                # NeXt-Gen Gateway
                $Result | add-member -memberType AliasProperty -name device -value xg
                $Result | add-member -memberType AliasProperty -name device_name -value xg_name
                $Result | add-member -memberType AliasProperty -name device_model -value xg_model
                $Result | add-member -memberType AliasProperty -name device_displayName -value xg_displayName
            }
            {$_ -match "EVT_BB"} {
                # Bridge
                $Result | add-member -memberType AliasProperty -name device -value bb
                $Result | add-member -memberType AliasProperty -name device_name -value bb_name
                $Result | add-member -memberType AliasProperty -name device_model -value bb_model
                $Result | add-member -memberType AliasProperty -name device_displayName -value bb_displayName
            }
            default {}
        }
    }
    $Results
    <#
        .SYNOPSIS
        List site alarms by most recent first, 3000 result limit.

        .DESCRIPTION
        List site alarms by most recent first, 3000 result limit. A generic "device" alias* has been added to many of the alarm events. 
        This allows for a common reference when retrieving the device's MAC, friendly name, model or display name rather than needing 
        to change the object property to support each different hardware model. The properties added to the API results are: device,
        device_name, device_model, and device_displayName.

        *Please note that there were several gueses as to which properties and hardware would be available for the various alarms. If 
        you find an alarm which is missing the generic device entries or find one that has blank values where values should be present, 
        please let the module author know.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER IncludeArchived
        Switch to return all alarms, including archived.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>    
}
