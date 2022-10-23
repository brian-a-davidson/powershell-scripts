$Services = Get-WmiObject -Class win32_service | where {($_.name -eq 'AltirisReceiverService') -or ($_.name -eq 'AltirisClientMsgDispatcher') -or ($_.name -eq 'AltirisSupportService') -or ($_.name -eq 'EventReceiver') -or ($_.name -eq 'W3SVC') -or ($_.name -eq 'aexsvc') -or ($_.name -eq 'ctdataloader') -or ($_.name -eq 'atrshost') -and ($_.state -eq 'stop pending')} 

if ($Services) {
    foreach ($service in $Services) {
        try {
                Stop-Process -Id $service.processid -Force -PassThru -ErrorAction Stop
            }
        catch {
                Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
            }
        }
    }
    else {
        Write-Output "There are currently no services with a status of 'Stopping'."
    }

