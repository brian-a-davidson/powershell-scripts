$servers_csv = import-csv c:\temp\servers_test.csv

foreach ($server in $servers_csv)
	{
    	$server_name = $server.Server_Name
	invoke-command -computername $server_name {Get-Service wuauserv  | Set-Service -StartupType Automatic  | Start-Service -PassThru}
	invoke-command -computername $server_name {gwmi win32_service -filter "name = 'wuauserv'"} | out-file -Append c:\temp\enable_wsus_service_results.txt
	}