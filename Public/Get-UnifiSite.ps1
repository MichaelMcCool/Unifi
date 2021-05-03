function Get-UnifiSite {
    [CmdletBinding(DefaultParameterSetName='None')]
    param ( 
        [Parameter(Mandatory=$true, ParameterSetName="IncludeHealth")][switch]$IncludeHealth,
        [Parameter(Mandatory=$false, ParameterSetName="IncludeHealth")][switch]$Raw
    )

    if ($IncludeHealth) {
        $URI = "$controller/api/stat/sites"
    }
    else {
        $URI = "$controller/api/self/sites"
    }
    $RawResults=(Invoke-GetRestAPICall $URI).data
    if ($raw){
        $RawResults
    }
    else {
        if ($IncludeHealth){
            ForEach ($result in $RawResults){
                $result.health = ConvertTo-UnifiObject $result.health -Delimiter 'subsystem'
            }
        }
        $RawResults
    }

    <#
        .SYNOPSIS
        Retrieves the list of sites from the Unifi controller.

        .DESCRIPTION
        Retrieves the list of sites from the Unifi controller and optionally the health status and new alarm count.
        
        .PARAMETER IncludeHealth
        Switch to also return basic health information and new alarm count.

        .PARAMETER Raw
        Switch to return the raw health results as received from the API.

        .INPUTS
        None.

        .OUTPUTS
        System.Object. 
    #>
}
