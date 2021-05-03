
function Invoke-GetRestAPICall {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)] `
            [string]$url,
        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)] `
            [System.Collections.Generic.Dictionary[[String], [String]]]$headers
    )
    try {
        if ($headers) {
            $request = Invoke-RestMethod -Method GET -Headers $headers -Uri $url -WebSession $Session
        }
        else {
            $request = Invoke-RestMethod -Uri $url -WebSession $Session
        }
    }
    catch [System.Net.WebException] {
        $exceptionMessage = $_.Exception.Message

        switch ($exceptionMessage) {
            # Refresh the login if the cookie times out.
            "The underlying connection was closed: An unexpected error occurred on a send." {
                write-verbose "Connection timed out. Refreshing session."
                Connect-UnifiController -Refresh
                if ($headers) {
                    $request = Invoke-RestMethod -Method GET -Headers $headers -Uri $url -WebSession $Session
                }
                else {
                    $request = Invoke-RestMethod -Uri $url -WebSession $Session
                }
            }
            default {
                write-host "Error Message: $exceptionmessage"
                exit 1
            }
        }
    }

    return $request
}
