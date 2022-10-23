#Define Services 
     $Service1 = 'AltirisReceiverService'
     $Service2 = 'AltirisClientMsgDispatcher'
     $Service3 = 'AltirisSupportService'
     $Service4 = 'EventReceiver'
     $Service5 = 'W3SVC'
     $Service6 = 'ctdataloader'
     $Service7 = 'atrshost'
     $Service8 = 'aexsvc'

     $services = @(
     $Service1,
     $service2,
     $service3,
     $service4,
     $Service5,
     $Service6,
     $Service7,
     $Service8)

#View Services

     Get-WmiObject -Class win32_service | 
     Where { $Services -Contains $_.Name} |
     Foreach {
     $_ | select Name,ProcessID,State
     } 
