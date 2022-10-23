 $number=$args[0]
 get-childitem C:\ProgramData\Symantec\SMP\EventQueue\Temp\* -include *.nse | sort lastwritetime | select -first $number | move-item -destination C:\ProgramData\Symantec\SMP\EventQueue\EvtInbox\
