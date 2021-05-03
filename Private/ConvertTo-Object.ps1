function ConvertTo-Object($hashtable) {
   # This function is used internally by other commands. It's purpose is to convert hashtables, arrays and other 
   # types of objects into a PSCustomObject so a consistent method of accessing property names and values can be used.
   $object = New-Object PSCustomObject
   $hashtable.GetEnumerator() | 
      ForEach-Object { Add-Member -inputObject $object -memberType NoteProperty -name $_.Name -value $_.Value }
   $object
}