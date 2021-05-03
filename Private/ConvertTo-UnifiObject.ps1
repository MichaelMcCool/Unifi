
function ConvertTo-UnifiObject {
    param (
        [Parameter(Position=0, Mandatory = $true, ValueFromPipeline = $true)]$Object,
        [Parameter(Position=1, Mandatory = $true, ValueFromPipeline = $true)][String]$Delimiter,
        [Parameter(Position=2, Mandatory = $false, ValueFromPipeline = $true)][switch]$Filter
    )
    $NewObject=$null
    $NewObject = [PSCustomObject]@{}
    foreach ($Item in $Object){
        $NewSubObject=$null
        $NewSubObject=[PSCustomObject]@{}
        if ($Filter){
            # There are some junk duplicates which contain a _id value only. This filters those out from the new object.
            if (($Item | Get-Member -MemberType NoteProperty).count -gt 2) {
                foreach ($SubItem in $Item) {
                    $Props = $SubItem | get-member -membertype NoteProperty
                    foreach($Prop in $Props) {
                        $NewSubObject | Add-member -MemberType NoteProperty -Name $Prop.name -Value $SubItem.($Prop.name)
                    }
                }
                $NewObject | add-member -MemberType NoteProperty -name $Item.$Delimiter -value $NewSubObject
            }
        }
        else {
            foreach ($SubItem in $Item) {
                $Props = $SubItem | get-member -membertype NoteProperty
                foreach($Prop in $Props) {
                    $NewSubObject | Add-member -MemberType NoteProperty -Name $Prop.name -Value $SubItem.($Prop.name)
                }
            }
            $NewObject | add-member -MemberType NoteProperty -name $Item.$Delimiter -value $NewSubObject
        }
        
    }
    $NewObject
    <#
    .SYNOPSIS
    This function is used internally to help format certain REST API results.

    .DESCRIPTION
    This function is used internally to help format certain REST API results. Some results are simply an array of objects rather than something which is easily used.
    For example, in the raw REST API data, if you had the site settings stored in $UnifiSiteSettings, you would need the following command to view the provider upload speed:
    ($UnifiSiteSettings | where-object {$_.key -eq "provider_capabilities"}).upload. With this reformatted, one can simply use $UnifiSiteSettings.provider_capabilities.upload for the same results.

    .PARAMETER Object
    This is the object that will be converted.

    .PARAMETER Delimiter
    This is the key value in the Object data which is used for the reference when converting. This value must exist for all objects in the array.
    
    .PARAMETER Filter
    This is a switch parameter to indicate if the function should filter out subitems with just one entry.
    

    .INPUTS
    System.Object, System.String, Switch.

    .OUTPUTS
    System.Object.
    #>
}