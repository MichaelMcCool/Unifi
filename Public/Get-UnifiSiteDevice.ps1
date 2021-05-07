function Get-UnifiSiteDevice {
    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    param (
        [Parameter(ParameterSetName="Detailed", Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName="Basic", Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string]$name,
        [Parameter(ParameterSetName="Detailed")][switch]$Detailed,
        [Parameter(ParameterSetName="Detailed")]$MAC
    )
    $BasicURI="$controller/api/s/$name/stat/device-basic"
    $DetailedURI="$controller/api/s/$name/stat/device"

    
    if (!$Detailed){
        #Return basic information only.
        (Invoke-GetRestAPICall $BasicURI).data
    }
    else {
        if ($PSBoundParameters.ContainsKey('mac')){

            if ($mac -is [array]){
                # Normalize the mac addresses in the array to colon separated pairs.
                for ($i=0; $i -lt $mac.Length; $i++){
                    $mac[$i] = $mac[$i] -replace "([0-9a-f]{2})[^0-9a-f]?(?=.)",'$1:'
                }
                # If $mac is an array, use it as is.
                $Params=@{
                    macs = $mac
                }
            }
            else {
                # If $mac isn't an array, it should be a string.
                # Normalize the mac address to colon separated pairs.
                $mac = $mac -replace "([0-9a-f]{2})[^0-9a-f]?(?=.)",'$1:'
                
                # If $mac is a string, turn it into an array.
                $Params=@{
                    macs = @($mac)
                }
            }
            $body = New-UnifiCommand $params
            write-verbose $body
            $DeviceDetailed=(Invoke-POSTRestAPICall -url $DetailedURI -payload $body).data
        }
        else {
            $DeviceDetailed=(Invoke-GetRestAPICall $DetailedURI).data
        }
        $DeviceBasic=(Invoke-GetRestAPICall $BasicURI).data
       
        # The detailed results are missing the 'disabled' property, so the basic info is not a subset of the detailed info.
        # Add the 'disabled' property to the deatiled device information.
        write-verbose "Adding missing property `'disabled`' to detailed device information."
        foreach ($entry in $DeviceDetailed){
            $Basic=$DeviceBasic | Where-Object {$_.mac -eq $entry.mac}
            $entry | Add-Member -MemberType NoteProperty -name 'disabled' -value $Basic.disabled
        }
        $DeviceDetailed
    }
    <#
        .SYNOPSIS
        List site devices.

        .DESCRIPTION
        List site devices. For all device information, use the -Detailed switch.

        .NOTES
        The detailed results are missing the 'disabled' property from the API, so the basic device information is not a true subset of the detailed information.
        This has been "fixed" in this command by adding the missing property from the basic device information to the detailed device information.

        .PARAMETER Name
        Short name for the site. This is the 'name' value from the Get-UnifiSite command.

        .PARAMETER Detailed
        Switch to include full device details.

        .PARAMETER Mac
        Limit results to a specific MAC address(es). Value may be an array or string.
        
        .INPUTS
        System.String. Can take value from pipeline.

        .OUTPUTS
        System.Object.
    #>
}