
Function Get-UnifiEventStrings {
    [CmdletBinding()]
    Param(
        [string]$Language = "en"
    )
    $ControllerName=Get-UnifiControllerName
    write-verbose "Extracting event strings for language: $Language"
    $URI = "$controller/manage/angular/$ControllerName/locales/$($Language.tolower())/eventStrings.json"
    (Invoke-GetRestAPICall $URI)

    <#
        .SYNOPSIS
        Extracts the event strings from the controller language files.

        .DESCRIPTION
        Extracts the event strings from the controller language files. This can be useful when developing certain scripts which require
        knowledge of all possible events which can be generated.

        .PARAMETER Language
        The two letter code for the language. Languages other than English (en) are a beta feature in the Unifi product and may not be available.
        If this value is ommited, English (en) will be used.

        .INPUTS
        None.

        .OUTPUTS
        System.Object.
    #> 
}