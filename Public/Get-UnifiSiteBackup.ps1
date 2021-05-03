function Get-UnifiBackup {
    [CmdletBinding()]
    param ()
    $params = @{
        cmd   = "list-backups"
    }
    $body = New-UnifiCommand $params
    $URI = "$controller/api/s/default/cmd/backup"
    (Invoke-POSTRestAPICall -url $URI -payload $body).data
    <#
        .SYNOPSIS
        List of autobackup files.

        .DESCRIPTION
        List of autobackup files.

        .NOTES
        This particular command is issued with a site specified, but it global for the controller. As such, I have 
        hard coded the command to use the 'default' site and to be a global command rather than site specific command.
        If this is determined not to be the case, please let me know.

        .INPUTS
        None.

        .OUTPUTS
        System.Object.
    #>
}