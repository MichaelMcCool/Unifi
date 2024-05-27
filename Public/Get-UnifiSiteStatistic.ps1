function Get-UnifiSiteStatistic {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$name,
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)][ValidateSet('ap','site','sw', 'gw', IgnoreCase=$false)]$type,
        [Parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $true)][ValidateSet('hourly','5minutes','daily')][string]$timescale,
        $MAC,
        $DateStart,
        $DateEnd
    )
    $params = @{
        attrs = @(
            'satisfaction',
            'bytes',
            'num_sta',
            'time',
            'tx_packets',
            'rx_packets',
            'wan-tx_packets',
            'wan-rx_packets',
            'lan-tx_packets',
            'lan-rx_packets',
            'lan2-tx_packets',
            'lan2-rx_packets',
            'tx_dropped',
            'rx_dropped',
            'wan-tx_dropped',
            'wan-rx_dropped',
            'lan-tx_dropped',
            'lan-rx_dropped',
            'lan2-tx_dropped',
            'lan2-tx_dropped',
            'wifi_tx_attempts',
            'wifi_tx_dropped',
            'rx_errors',
            'tx_errors',
            'wan-rx_errors',
            'wan-tx_errors',
            'lan-rx_errors',
            'lan-tx_errors',
            'lan2-rx_errors',
            'lan2-tx_errors',
            'tx_retries',
            'rx_frags',
            'rx_crypts',
            'wan-tx_bytes',
            'wan-rx_bytes',
            'lan-rx_bytes',
            'lan-tx_bytes',
            'lan2-rx_bytes',
            'lan2-tx_bytes',
            'wlan_bytes',
            'lan-num_sta', 
            'wlan-num_sta', 
            'rx_bytes', 
            'tx_bytes',
            'mem',
            'cpu',
            'loadavg_5'
        )
        n = 1
    }
    # Use the provided start and end times if provided, if not, generate a date range based on the time scale selected.
    if ($PSBoundParameters.ContainsKey('DateStart')){
        $start=Convert-ToUnixDate -LocalDate $DateStart -units Milliseconds
    }
    else {
        switch ($timescale){
            '5minutes'  {
                $start=Convert-ToUnixDate -LocalDate (Get-Date(Get-Date -Format "MM/dd/yyyy HH:00:00")).addhours(-1) -units Milliseconds
            }
            'hourly'  {
                $start=Convert-ToUnixDate -LocalDate (Get-Date).Date -units Milliseconds
            }
            'daily' {
                $start=Convert-ToUnixDate -LocalDate  ((Get-Date).Date).AddDays(-6) -units Milliseconds
            }
        }
    }
    if ($PSBoundParameters.ContainsKey('DateEnd')){
        $end=Convert-ToUnixDate -LocalDate $DateEnd -units Milliseconds
    }
    else {
        switch ($timescale){
            '5minutes'  {
                $end=Convert-ToUnixDate -LocalDate (Get-Date(Get-Date -Format "MM/dd/yyyy HH:00:00")).AddHours(1) -units Milliseconds
            }
            'hourly'  {
                $end=Convert-ToUnixDate -LocalDate (Get-Date).Date.AddDays(1) -units Milliseconds
            }
            'daily' {
                $end=Convert-ToUnixDate -LocalDate  ((Get-Date).Date).AddDays(1) -units Milliseconds
            }
        }
    }

    # Add the start and end times.
    $Params.add('start',$start)
    $Params.add('end',$end)

    # Standardize MAC entries and add to params table.
    if ($PSBoundParameters.ContainsKey('mac')){
        if ($mac -is [array]){
            # Normalize the mac addresses in the array to colon separated pairs.
            for ($i=0; $i -lt $mac.Length; $i++){
                $mac[$i] = $mac[$i] -replace "([0-9a-f]{2})[^0-9a-f]?(?=.)",'$1:'
            }
            # If $mac is an array, use it as is.
            $Params.add('macs',$mac)
        }
        else {
            # If $mac isn't an array, it should be a string.
            # Normalize the mac address to colon separated pairs.
            $mac = $mac -replace "([0-9a-f]{2})[^0-9a-f]?(?=.)",'$1:'
            
            # If $mac is a string, turn it into an array.
            $Params.add('macs',@($mac))
        }
    }


    $body = New-UnifiCommand $params
    $URI = "$controller/api/s/$name/stat/report/$timescale.$type"
    write-verbose $uri
    
    (Invoke-PostRestAPICall $URI -payload $body).data
    <#
        .SYNOPSIS
        Report the statistics.

        .DESCRIPTION
        Report the statistics for the specified site. Can show site, AP, gateway or switch data.

        All datapoints are returned. The following is a list of datapoints used for each performance table:

        Description                     Field
        -----------------------------   ----------------
        Avg. WiFi User Experience [%]   satisfaction
        User Count (Clients)            num_sta
        LAN User Count (Clients)        lan-num_sta
        WiFi User Count (Clients)       wlan-num_sta
        Performance
            Memory [%]                  mem
            CPU [%]                     cpu
            5 minute load average       loadavg_5
        Traffic
            Received [bytes]            rx_bytes
            Tranmitted [bytes]          tx_bytes
        Traffic [Gateway]
            WAN1 Received [bytes]       wan-rx_bytes
            WAN1 Transmitted [bytes]    wan-tx_bytes
            LAN1 Received [bytes]       lan-rx_bytes
            LAN1 Transmitted [bytes]    lan-tx_bytes
            LAN2 Received [bytes]       lan2-rx_bytes
            LAN2 Transmitted [bytes]    lan2-tx_bytes
        Packets
            Received                    rx_packets
            Transmitted                 tx_packets
        Packets [Gateway]
            WAN1 Received               wan-rx_packets
            WAN1 Transmitted            wan-tx_packets
            LAN1 Received               lan-rx_packets
            LAN1 Transmitted            lan-tx_packets
            LAN2 Received               lan2-rx_packets
            LAN2 Transmitted            lan2-tx_packets
        Dropped Packets
            Received                    rx_dropped
            Transmitted                 tx_dropped
        Dropped Packets [Gateway]
            WAN1 Received               wan-rx_dropped
            WAN1 Transmitted            wan-tx_dropped
            LAN1 Received               lan-rx_dropped
            LAN1 Transmitted            lan-tx_dropped
            LAN2 Received               lan2-rx_dropped
            LAN2 Transmitted            lan2-tx_dropped
        WiFi Transmit Attempts          wifi_tx_attempts
        WiFi Transmit Dropped           wifi_tx_dropped
        Errors
            Receive Errors              rx_errors
            Transmit Errors             tx_errors
        Errors [Gateway]
            WAN1 Received Errors        wan-rx_errors
            WAN1 Transmitted Errors     wan-tx_errors
            LAN1 Received Errors        lan-rx_errors
            LAN1 Transmitted Errors     lan-tx_errors
            LAN2 Received Errors        lan2-rx_errors
            LAN2 Transmitted Errors     lan2-tx_errors
        Transmit Retries                tx_retries
        Fragmentation                   rx_frags
        Rx Invalid Crypts               rx_crypts

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER type
        The type of statistics to obtain--Access Point (ap), Site, Gateway (gw), Switch (sw).

        .PARAMETER timescale
        Data interval--daily,hourly,5minutes.
        
        .PARAMETER MAC
        List of MAC addresses to filter upon. Can be a string or array. If ommited, only the first 
        device of the specified report type will be selected.

        .PARAMETER DateStart
        Start time. Default values will be generated based on timescale if ommited.

        .PARAMETER DateEnd
        End time. Default values will be generated based on timescale if ommited.

        .INPUTS
        System.Object. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}