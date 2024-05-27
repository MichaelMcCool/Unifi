Function Convert-ToUnixDate {
    param (
        $LocalDate,
        [ValidateSet('Seconds','Milliseconds', IgnoreCase=$false)]$units
    )
    switch ($units){
        "Seconds"   {
            ([timezone]::CurrentTimeZone.ToUniversalTime((Get-date $LocalDate))-(Get-date "1/1/1970")).TotalSeconds
        }
        "Milliseconds"  {
            ([timezone]::CurrentTimeZone.ToUniversalTime((Get-date $LocalDate))-(Get-date "1/1/1970")).TotalMilliseconds
        }
    }
}