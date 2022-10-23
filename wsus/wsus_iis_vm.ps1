$value = (Get-Process w3wp | select vm -last 1).vm
$display = [System.Math]::Abs($value)
Write-output $display