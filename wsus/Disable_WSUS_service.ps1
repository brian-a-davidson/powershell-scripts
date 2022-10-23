$servers_csv = import-csv c:\temp\servers.csv

foreach ($server in $servers_csv)
	{
    $server_name = $server.Server_Name
	invoke-command -computername $server_name {Get-Service wuauserv | Stop-Service -PassThru | Set-Service -StartupType disabled}
	invoke-command -computername $server_name {gwmi win32_service -filter "name = 'wuauserv'"} | out-file -Append c:\temp\wsus_service_results.txt
	}