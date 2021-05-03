function Clear-UnifiSiteAlarm {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ID')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName='ID')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName='ClearAll')]
        [string]$name,
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName='ID')]
        [string]$ID,
        [Parameter(ParameterSetName='ClearAll')][switch]$ClearAll
    )
    if ($ClearAll) {
        $params = @{
            cmd = "archive-all-alarms"
        }
        $body = New-UnifiCommand $params
        $URI = "$controller/api/s/$name/cmd/evtmgr"
        if ($PSCmdlet.ShouldProcess($URI,"Clear All Alarms")){
            $null = Invoke-POSTRestAPICall -url $URI -payload $body
        }
    }
    else {
        $params = @{
            cmd = "archive-alarm"
            _id = $ID
        }
        $body = New-UnifiCommand $params
        $URI = "$controller/api/s/$name/cmd/evtmgr"
        if ($PSCmdlet.ShouldProcess($URI,"Archive alarm $ID")){
            $null = Invoke-POSTRestAPICall -url $URI -payload $body
        }
    }
    <#
        .SYNOPSIS
        Archive the specified site alarm.

        .DESCRIPTION
        Archive the specified site alarm. If the -ClearAll switch is used, all site alarms are archived.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER ID
        The _id value from the Get-UnifiSiteAlarm command.

        .PARAMETER ClearAll
        Switch value to indicate that all current alarms for the site should be archived.
        
        .INPUTS
        System.String.

        .OUTPUTS
        System.Object.
    #>    
}
