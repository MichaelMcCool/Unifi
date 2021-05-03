function New-UnifiCommand {
    param(
        [Parameter(Position = 0, Mandatory = $true)]$Object
    )
    $Object | ConvertTo-Json

    <#
        .SYNOPSIS
        Converts the object into a JSON formated string.

        .DESCRIPTION
        Converts the object into a JSON formated string. This is a helper command for building the proper structure for sending instructions to the Unifi controller api.
        This will not be used in script creation directly, but is leveraged by other commands in a modular fashion.
        
        .PARAMETER Object
        This can be a PSCustomObject, Array, ArrayList, HashTable or other value set that will work with the ConvertTo-Json cmdlet.

        .INPUTS
        System.Object. You cannot pipe values into this command.

        .OUTPUTS
        System.String. JSON formatted.
    #> 
}
