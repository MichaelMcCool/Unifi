# Get the list of valid protocols for creating firewall rules.
function Get-UnifiFirewallProtocol {
    [CmdletBinding()]
    param ()
    $ControllerName=Get-UnifiControllerName
    $URI = "$controller/manage/angular/$ControllerName/js/app.js"
    $WebResults=(Invoke-GetRestAPICall $URI)

    # To convert this properly we need a raw data stream.
    $Webresults | out-file -FilePath "$env:TEMP\Webresults.txt"
    $TempData = Get-content $env:temp\Webresults.txt  -raw
    Remove-Item -Path "$env:TEMP\Webresults.txt"

    # Extract the relevant function from the javascript.
    $FullRegex='(?<=957:\[function\(e,t,n\)).*(?=,\{\}\],958:\[function\(e,t,n\))'
    [void]($tempData -match $FullRegex)
    $FunctionData=$Matches.0

    # Extract the json data and convert into a powershell object.
    $GroupRegex='(?<="FIREWALL",).*(?=\)\})'
    [void]($FunctionData -match $GroupRegex)
    $GroupData=$Matches.0 | ConvertFrom-Json
    
    # Make a new PSCustomObject with just the protocol data.
    $Protocols= [PSCustomObject] @{
        IPV4 = $GroupData.IPV4
        IPV6 = $GroupData.IPV6
    }
    
    # The ICMP types include an empty value in the data. Remove the empty value.
    $Protocols.IPV4.ICMP_TYPES = $Protocols.IPV4.ICMP_TYPES | where-object {!([string]::IsNullOrWhiteSpace($_))}
    $Protocols.IPV6.ICMP_TYPES = $Protocols.IPV6.ICMP_TYPES | where-object {!([string]::IsNullOrWhiteSpace($_))}

    # Return the modified data for use elsewhere.
    $Protocols

    <#
        .SYNOPSIS
        Returns information on the various valid protocol selections for firewall rules.

        .DESCRIPTION
        Returns information on the various valid protocol selections for firewall rules. 
        
        .INPUTS
        None.

        .OUTPUTS
        System.Object.
    #>
}