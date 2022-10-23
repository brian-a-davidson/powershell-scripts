$value = (Get-Process w3wp | select vm -last 1).vm
$display = [System.Math]::Abs($value)
$vm = ($display / 1MB)
write-output "$Vm MB"