

function Invoke-POSTRestAPICall {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)] `
            [string]$url,
        [Parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $true)] `
            [string]$payload,
        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)] `
            [System.Collections.Generic.Dictionary[[String], [String]]]$headers
    )

    try {
        if ($headers) {
            $request = Invoke-RestMethod -Method POST -Headers $headers -Body $payload -Uri $url -ContentType "application/json; charset=utf-8" -WebSession $Session
        }
        else {
            $request = Invoke-RestMethod -method POST -Body $payload -Uri $url -ContentType "application/json; charset=utf-8" -WebSession $Session
        }
    } 
    
    catch [System.Net.WebException] {
        $exceptionError = $_.Exception
        $exceptionMessage = $_.Exception.Message

        switch ($exceptionMessage) {
            # Refresh the login if the cookie times out.
            "The remote server returned an error: (401) Unauthorized." {
                write-verbose "Connection timed out. Refreshing session."
                Connect-UnifiController -Refresh
                if ($headers) {
                    $request = Invoke-RestMethod -Method POST -Headers $headers -Body $payload -Uri $url -ContentType "application/json; charset=utf-8" -WebSession $Session
                }
                else {
                    $request = Invoke-RestMethod -Body $payload -Uri $url -ContentType "application/json; charset=utf-8" -WebSession $Session
                }
            }
            default {
                write-host "Error Message: $ExceptionMessage"
                exit 1
            }
        }
    }
    return $request
}