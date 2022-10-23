$value = (Get-Process w3wp | select vm -last 1).vm
$display = ($value * -1 /1024/1024 + 320)
Write-output ("{0:N0}" -f $display)

Read-Host -Prompt "Press Enter to exit"