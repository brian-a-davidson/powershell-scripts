#Define Services 
     $Service1 = 'AltirisReceiverService'
     $Service2 = 'AltirisClientMsgDispatcher'
     $Service3 = 'AltirisSupportService'
     $Service4 = 'EventReceiver'
     $Service5 = 'W3SVC'
     $Service6 = 'ctdataloader'
     $Service7 = 'atrshost'
 #    $Service8 = 'aexsvc'

     $services = @(
     $Service1,
     $Service2,
     $Service3,
     $Service4,
     $Service5,
     $Service6,
     $Service7)
 #    $Service8)

#Stop Services

     Get-service | 
     Where { $Services -Contains $_.Name} |
     Foreach {

     $_ | stop-service

     } 
	
# Stop the AEXsvc Service	
	Do 
	{
	Write-host "Waiting for Dependency Services to stop...`n`n"
	}
	until (((Get-Service $Service1).Status -eq "stopped") -and ((Get-Service $Service2).Status -eq "stopped" ))
stop-service aexsvc -Force
$Services += 'aexsvc'	
	 
	
#     Set-Service |
#     Where { $Services -Contains $_.Name} |
#     Foreach {
#
#    $_ | -startuptype "Disabled"
#
#     }

#Verify Services

     Get-service | 
     Where { $Services -Contains $_.Name} |
     Foreach {

     if ((Get-Service $_.Name).Status -eq "stopped") {Write-Host $_.Name '- stopped'} else {Write-Host $_.Name '- check status'}

     }
