function Set-UnifiSiteDevice {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="Adopt")]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="Restart")]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="Provision")]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="PowerCycle")]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="SpeedTest")]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="Locate")]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="Upgrade")]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="Migrate")]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="Scan")]
        [string]$name,
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="Adopt")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="Restart")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="Provision")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="PowerCycle")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="Locate")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="Upgrade")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="Migrate")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="Scan")]
        [string]$mac,
        [Parameter(ParameterSetName="Adopt", Mandatory = $true)][switch]$Adopt,
        [Parameter(ParameterSetName="Restart", Mandatory = $true)][switch]$Restart,
        [Parameter(ParameterSetName="Provision", Mandatory = $true)][switch]$Provision,
        [Parameter(ParameterSetName="PowerCycle", Mandatory = $true)][switch]$PowerCycle,
        [Parameter(ParameterSetName="PowerCycle", Mandatory = $true)][int]$Port,
        [Parameter(ParameterSetName="SpeedTest", Mandatory = $true)][switch]$SpeedTest,
        [Parameter(ParameterSetName="SpeedTest")][switch]$Status,
        [Parameter(ParameterSetName="Locate", Mandatory = $true)][Boolean]$Locate,
        [Parameter(ParameterSetName="Upgrade", Mandatory = $true)][switch]$Upgrade,
        [Parameter(ParameterSetName="Upgrade")]
        [Parameter(ParameterSetName="Migrate", Mandatory = $true)][string]$URL,
        [Parameter(ParameterSetName="Migrate", Mandatory = $true)][Boolean]$migrate,
        [Parameter(ParameterSetName="Scan", Mandatory = $true)]
        [switch]$Scan
    )

    $URI="$controller/api/s/$name/cmd/devmgr"
    
    # Get the detailed device information for this device.
    if ($PsCmdlet.ParameterSetName -ne 'SpeedTest'){
        # Normalize the Mac address
        $mac = $mac -replace "([0-9a-f]{2})[^0-9a-f]?(?=.)",'$1:'
        
        $Device=Get-UnifiSiteDevice -name $name -Detailed -mac $mac
    }

    switch ($PsCmdlet.ParameterSetName) {
        'Adopt' {
            write-verbose $_
            $params = @{
                cmd = "adopt"
                mac = $mac
            }
            $body = New-UnifiCommand $params
            write-verbose $body
            if ($PSCmdlet.ShouldProcess($mac,'Adopt')){
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
            }
        }
        'Restart' {
            write-verbose $_
            $params = @{
                cmd = "restart"
                mac = $mac
            }
            $body = New-UnifiCommand $params
            write-verbose $body
            if ($PSCmdlet.ShouldProcess($mac,'Restart')){
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
            }
        }
        'Provision' {
            write-verbose $_
            $params = @{
                cmd = "force-provision"
                mac = $mac
            }
            $body = New-UnifiCommand $params
            write-verbose $body
            if ($PSCmdlet.ShouldProcess($mac,'Provision')){
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
            }
        }
        'PowerCycle' {
            write-verbose $_
            if ($device.type -eq 'usw'){
                $params = @{
                    cmd = "power-cycle"
                    mac = $mac
                    port_idx = $Port
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                if ($PSCmdlet.ShouldProcess($mac,'Power cycle')){
                    $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                    
                }
            }
            else {
                write-host "Device $mac is not a switch."
            }
            
        }
        'SpeedTest' {
            write-verbose $_
            if ($PSBoundParameters.ContainsKey('Status')) {
                $params = @{
                    cmd = "speedtest-status"
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                $Response.data
            }
            else {
                $params = @{
                    cmd = "speedtest"
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                write-host "Started speed test. Please wait a minute before checking results."
            }
        }
        'Locate' {
            write-verbose $_
            if ($locate -eq $true){
                $params = @{
                    cmd = "set-locate"
                    mac = $mac
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                write-host "Blinking LED."
            }
            else {
                $params = @{
                    cmd = "unset-locate"
                    mac = $mac
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                write-host "Unblinking LED."
            }
        }
        'Upgrade' {
            write-verbose $_
            if ($Device.State -ne 1){
                write-host "Device $mac is not ready."
                exit
            }
            if ($PSBoundParameters.ContainsKey('URL')) {
                # This is the custom-upgrade section by specifying a URL.
                $params = @{
                    cmd = "upgrade-external"
                    mac = $mac
                    url = $URL
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                if ($PSCmdlet.ShouldProcess($mac,'Upgrade firmware')){
                    $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                    if ($response.meta.rc -eq 'ok'){
                        write-host "Started firmware installation on device $mac."
                    }
                    else {
                        write-host "Recieved error `"${$response.meta.rc}`" for device $mac."
                    }
                }
            }
            else {
                # This is the auto-upgrade section handled by the controller.
                if ($Device.upgradable -eq $true) {
                    # It appears that the firmware is always updated to the latest no matter what value is specified for upgrade_to_firmware
                    $params = @{
                        cmd = "upgrade"
                        mac = $mac
                        upgrade_to_firmware = $device.upgrade_to_firmware
                    }
                    $body = New-UnifiCommand $params
                    write-verbose $body
                    if ($PSCmdlet.ShouldProcess($mac,'Upgrade firmware')){
                        $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                        if ($response.meta.rc -eq 'ok'){
                            write-host "Started firmware upgrade on device $mac."
                        }
                        else {
                            write-host "Recieved error `"${$response.meta.rc}`" for device $mac."
                        }
                    }
                }
                else {
                    write-host "No updates found for device $mac."
                }
            }
        }
        'Migrate' {
            write-verbose $_
            if ($migrate -eq $true){
                $params = @{
                    cmd = "migrate"
                    inform_url = $URL
                    mac = $mac
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                if ($PSCmdlet.ShouldProcess("Update Inform URL ($URL) for target `"$mac`"?",$mac,'Migrate')){
                    $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                }
            }
            else {
                $params = @{
                    cmd = "cancel-migrate"
                    mac = $mac
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
            }
            
        }
        'Scan'{
            write-verbose $_
            if ($device.type -eq 'uap'){
                $params = @{
                    cmd = "spectrum-scan"
                    mac = $mac
                }
                $body = New-UnifiCommand $params
                write-verbose $body
                $Response=(Invoke-POSTRestAPICall -url $URI -payload $body)
                $response
                write-host "Started spectrum scan."

            }
            
        }
        default {throw "Unknown command $_."}
    }
}
