function Get-UnifiControllerName {
    [CmdletBinding()]
    param()
    $URI = "$controller/manage/site/default/dashboard"

    $results=(Invoke-GetRestAPICall $URI)
    
    if ($results -match "(?<=angular\/).*?(?=\/)") {
        write-verbose "Successfully extracted controller name from webpage."
        $matches.0
    }
    else {
        write-verbose "Unable to extract controller name from dashboard webpage."
    }

    <#
        .SYNOPSIS
        Returns the short name for the controller itself.

        .DESCRIPTION
        Returns the short name for the controller itself. This is needed for pulling locale specific strings from the controller.

        This is an ugly hack to get the required data as the controller name doesn't seem to be available elsewhere in the API.
        It is however part of the image resource URIs inside the dashboard webpage. This command simply extracts that short name 
        so we can pull the other locale strings dynamically.
        
        .INPUTS
        None.

        .OUTPUTS
        System.String.
    #>
}
