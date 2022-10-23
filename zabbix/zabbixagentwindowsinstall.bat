#Uninstalls old agent if present
cd \zabbix\
zabbix_agentd.exe --config zabbix_agentd.conf --stop
zabbix_agentd.exe --config zabbix_agentd.conf --uninstall

#Copys all new files
mkdir C:\zabbix
copy /v /y "\\cernerwhq1.northamerica.cerner.net\grid\GRIDCSM\Documentation\Applications_Team\Zabbix\Windows\Corp_Windows\win64\zabbix_agentd.conf" c:\zabbix
copy /v /y "\\cernerwhq1.northamerica.cerner.net\grid\GRIDCSM\Documentation\Applications_Team\Zabbix\Windows\Corp_Windows\win64\zabbix_agentd.exe" c:\zabbix
copy /v /y "\\cernerwhq1.northamerica.cerner.net\grid\GRIDCSM\Documentation\Applications_Team\Zabbix\Windows\Corp_Windows\win64\zabbix_get.exe" c:\zabbix
copy /v /y "\\cernerwhq1.northamerica.cerner.net\grid\GRIDCSM\Documentation\Applications_Team\Zabbix\Windows\Corp_Windows\win64\zabbix_sender.exe" c:\zabbix
copy /v /y "\\cernerwhq1.northamerica.cerner.net\grid\GRIDCSM\Documentation\Applications_Team\Zabbix\Windows\Corp_Windows\win64\zabbixagentwindowsuninstall.bat" c:\zabbix
copy /v /y "\\cernerwhq1.northamerica.cerner.net\grid\GRIDCSM\Documentation\Applications_Team\Zabbix\Windows\Corp_Windows\win64\zabbixagentwindowsinstall.bat" c:\zabbix
C:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.conf --install
c:\zabbix\zabbix_agentd.exe --start --config c:\zabbix\zabbix_agentd.conf