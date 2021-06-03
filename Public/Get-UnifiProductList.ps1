function Get-UnifiProductList {
    [CmdletBinding()]
    param (
        [switch]$Detailed
    )

    function StreamCount {
        [CmdletBinding()]
        param (
            [int]$start,
            $object
        )
        $i=$Start
        $brcount=0
        $Loopbreak=$false
        $InLoop=$false
        while ($loopbreak -eq $false){
            $char=$object[$i]
            if ($char -eq "{"){
                $brcount++
            }
            if ($brcount -gt 0){
                $InLoop=$true
            }
            if ($char -eq "}"){
                $brcount--
            }
            if ($inloop -eq $true){
                if ($brcount -eq 0){
                    $loopbreak=$true
                }
            }
            write-verbose "Char: $char - Count: $i - BR: $brcount $Inloop"
            if ($InLoop -eq $true){
                if ($brcount -eq 0){
                    $loopbreak=$true
                }
            }
            if ($i -ge $object.length) {
                $Loopbreak=$true
            }
            $i++
        }
        $i
    }

    function StreamString {
        param (
            $Start,
            $End,
            $Data
        )
        $RelLength=$End-$Start
        $Data.substring($start,$Rellength)
    }

    $ControllerName=Get-UnifiControllerName
    $URI = "$controller/manage/angular/$ControllerName/js/app.js"
    $WebResults=(Invoke-GetRestAPICall $URI)

    $Webresults | out-file -FilePath "$env:TEMP\Webresults.txt"

    $FullRegex='(?<={1:\[function\(e,t,n\)\{t\.exports=\{).*(?=,\{\}\],2:\[function\(e,t,n\))'
    $TempData = Get-content "$env:TEMP\webresults.txt"  -raw 
    Remove-Item -Path "$env:TEMP\Webresults.txt"
    [void]($tempData -match $FullRegex)
    $DataToParse=$Matches.0

    $i=0
    $Start=0
    $DeviceData=[System.Collections.ArrayList]@()
    do {
        $EndCount=StreamCount -start $Start -object $DataToParse
        # $Start
        # $Endcount
        if ($endcount -gt $DataToParse.Length){
            $Endcount=$DataToParse.Length
        }
        $String=(StreamString -start $start -end $EndCount -data $DataToParse).replace("`n","")
        if ($string.length -gt 5){
            [void]$DeviceData.Add($string)
        }
        $Start=$EndCount+1
    }
    until ($Endcount -ge $DataToParse.Length)

    if ($Detailed){
        # This object conversion script created by reddit user /u/marsonreddit
        $DeviceList = [System.Collections.Generic.List[psobject]]::new()
        # Apart from an illegal character in your data set, everything after <Device Code>: appear to be valid JSON
        $regex = '(:)(?!["{}\[\]])(?<illegal>[*~@#$%^&*()_+=><?!\/]+\w+[*~@#$%^&*()_+=><?!\/]{0})'
        foreach ($dev in $DeviceData) {
            $FirstColon = $dev.IndexOf(':')
            $code = $dev.Substring(0,$FirstColon)
            $details = $dev.Substring(($FirstColon + 1)) -replace $regex, ('{0}"{1}"' -f '$1', '${illegal}') | ConvertFrom-Json
            [void]$DeviceList.Add(
                [PSCustomObject]@{
                    DeviceCode = $code.replace("`"","")
                    DeviceDetails = $details
                }
            )
        }

        $DeviceList
    }
    else {
        $RegexName='(?<=name:\").*?(?=\")'
        $RegexType='(?<=type:\").*?(?=\")'
        $DeviceDataParsed=[System.Collections.ArrayList]@()
        foreach ($item in $DeviceData){
            $Device=(StreamString -start 0 -end ($Item.indexof(":")) -data $Item).replace("`"","") # A few items have quotes in the device name.
            [void]($item -match $regexName)
            $name=$matches.0
            [void]($item -match $regexType)
            $Type=$matches.0
            $Entry=[PSCustomObject]@{
                Model = $Device
                Type = $Type
                ProductName = $Name
            }
            [void]$DeviceDataParsed.add($Entry)
        }
        $DeviceDataParsed
    }
        <#
        .SYNOPSIS
        Returns information on all device models supported by the controller.

        .DESCRIPTION
        Returns information on all device models supported by the controller. By default, this will return a list of just the model, type and name.
        Use the -Detailed switch to return a list of all information available. This includes items like radio and port information as well as 
        physical port layout. The structure of the data is different for each option.

        .PARAMETER Detailed
        Switch to retrieve all availeble model information.
        
        .INPUTS
        None.

        .OUTPUTS
        System.Object.
    #>
}


