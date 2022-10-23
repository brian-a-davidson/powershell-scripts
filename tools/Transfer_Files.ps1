<#
Script:	ABPTXFR.PS1

Purpose:  This script uses the WinSCP dll to SFTP files from the Windows application server to the database Unix/Linux server

Prerequisites:	Windows 2008 or later, Powershell, WinSCP 5.9.x or later, Powershell script execution set to "remote-signed"

To set Execuction Policy:	Set-ExecutionPolicy remotesigned

SSH Keys need to be created in PuttyGen.  Private key saved in .ppk format to the scripts\keys folder (restrict acccess to this folder)
On the Linux host add the Public ssh key data to the sftp users /home/<user>/.ssh/authorized_keys file
This file needs to be owned by the user and the users group.  Permissions need to be set to 600

Script by:		Brian Davidson
Script Date:	2016-09-08

Rev:	1.0
Rev History:
	1.0		-	Base Script
#>

<# 
Define Global Variables and Settings (User edits are in this section)
A comma needs to follow each variable except the last one.
#>
param (
	## Only edit this variable to determine server to use
	$selectSvr = 1				# <-- Select active server here
	,							# <-- comma moved here so editing above doesnt break code

	## Project information
	$projectName = "Project_Name"
	,
	$targetUser = "abpfiles"
	,							# <-- comma moved here so editing above doesnt break code
	## Email Alert Settings - For Operations Team Only, do not send to help desk
	$mailAlerts = 0				# <-- 0 = disable emailed alerts, 1 = enable email alerts
	,							# <-- comma moved here so editing above doesnt break code
	$mailFrom = "test-email@gmail.com",
	$mailTo = "test-email@gmail.com",
	$mailServer = "mail.company.local",

	## Debug Session toggle
	$debugSession = 0			# <-- 1 = enable session debug, 0 = disable session debug (default)
	,							# <-- comma moved here so editing above doesnt break code
	
	<#
	Define whats where							
	Folder paths must end with the / or \ (depending on Windows or Linux)
	#>
	$winscpPath = "C:\Program Files (x86)\WinSCP\",
	$initialSync = "C:\DWdownload\*.abp",
	$processPath = "C:\DWdownload\processing\",
	$processFiles = "$processPath\*",	# <-- Process Path needs to be identified two times, with and without files, not using this will create another subfolder on remote host
	$remotePath = "/home/shared/",
	$backupPath = "C:\DWdownload\sent\",
	$logFolder = "C:\DWdownload\logs\",
	$logFile = "abptxfr.$(Get-Date -UFormat '%Y-%m-%d').log",
	$logPath = "$logFolder$LogFile",
	$sessionFile = "session-$(Get-Date -UFormat '%Y-%m-%d').log",
	$sessionLog = "$logFolder$sessionFile",
	
	## HouseCleaning values
	$daysLogs = 	14			# <-- Select active server here
	,					# <-- comma moved here so editing above doesnt break code
	$daysArchive =	5			# <-- Select active server here
	,					# <-- comma moved here so editing above doesnt break code
	
	## Clear and define variables
	$alertStatus ="0",
	$alertMsg = "",
	$targetSvr = "",
	$targetSshFinger = "",
	$targetKeyFile = "",
	$targetPassPhrase = "",
	$Message = ""		# <-- Last variable defined, no comma!
)

<#
Define functions, the only section that should be edited here is the "select-Server" function
Add your target server options and their SSH finger information, you can add more numbers as needed, ending with the default
#>
function select-Server
{
	switch ($selectSvr) {
		1 {
			$targetSvr = "database-server.company.local"
			$targetSshFinger = "ssh-rsa 2048 5b:5e:a2:55:36:88:9c:90:ad:78:26:2a:21:60:6d:5f"
			$targetKeyFile = "C:\DWdownload\Scripts\Keys\abptxfr.ppk"
			$targetPassPhrase = "sutter"
		}
		2 {
			$targetSvr = "database-server.company.local"
			$targetSshFinger = "ssh-rsa 2048 7c:39:80:eb:16:97:2f:9c:c0:68:6c:e5:2c:73:6d:96"
			$targetKeyFile = "C:\DWdownload\Scripts\Keys\abptxfr.ppk"
			$targetPassPhrase = "sutter"
		}
		default {
			$alertStatus = "1" 
			$alertMsg += "$(Get-Date  -UFormat '%Y-%m-%d %H:%M:%S') [CRITICAL] !! Invalid Server Selection !!`n"
			Write-Log "[CRITICAL] !! Invalid Server Selection !!"
			Write-Log "[END] Unable to run script, Check configuration - Aborting"
			processAlerts
			exit 1
		}
	}
	## Pass the variables back to the main scope
	Set-Variable -Name targetSvr -Value $targetSvr -Scope 1
	Set-Variable -Name targetSshFinger -Value $targetSshFinger -Scope 1
	Set-Variable -Name targetKeyFile -Value $targetKeyFile -Scope 1
	Set-Variable -Name targetPassPhrase -Value $targetPassPhrase -Scope 1
}

function validate-Folders
{
	if(!(Test-Path -Path $processPath )){
		New-Item -ItemType directory -Path $processPath
		Write-Log "[WARN] Staging Folder was missing on startup..."
	}
	if(!(Test-Path -Path $backupPath )){
		New-Item -ItemType directory -Path $backupPath
		Write-Log "[WARN] Backup Folder was missing on startup..."
	}
}

function stage-Activefiles
{
	Get-ChildItem $initialSync | foreach ($_) {
		try {
			Move-Item $_ -Destination $processPath -ErrorAction stop
			Write-Log "[STAGING] Staging File: $($_)"
		} Catch {
			$alertStatus = "1" 
			$alertMsg += "$(Get-Date  -UFormat '%Y-%m-%d %H:%M:%S') [WARN] Cannot Stage: $($_.TargetObject)`n"
			Write-Log "[WARN] File Already Staged: $($_.TargetObject)"
			
			#Pass the alert information back to the main process
			Set-Variable -Name alertStatus -Value $alertStatus -Scope 1
			Set-Variable -Name alertMsg -Value $alertMsg -Scope 1
		}
	}	
}

function transfer-Files
{
	Write-Log "[INFO] Begining File Transfer system to $targetSvr"
	try
	{
		# Load WinSCP .NET assembly
		#Add-Type -Path "$winscpDll"
		Add-Type -Path (Join-Path $winscpPath "WinSCPnet.dll")
 
		# Setup session options
		$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
			Protocol = [WinSCP.Protocol]::Sftp
			HostName = $targetSvr
			UserName = $targetUser
			SshPrivateKeyPath = $targetKeyFile
			PrivateKeyPassphrase = $targetPassPhrase
			SshHostKeyFingerprint = $targetSshFinger
		}
 
		$session = New-Object WinSCP.Session
		
		if ( $debugSession -eq 1 )
			{
				$session.SessionLogPath = $sessionLog
			}
		try
		{
			# Connect
			$session.Open($sessionOptions)
 
			# Upload files, collect results
			$transferResult = $session.PutFiles($processFiles, $remotePath)
 
			# Iterate over every transfer
			foreach ($transfer in $transferResult.Transfers)
			{
				# Success or error?
				if ($transfer.Error -eq $Null)
				{
                   			Write-Log ("[SUCCESS] Uploaded file: {0}" -f $transfer.FileName)
					# Upload succeeded, move source file to backup
					try {
					Move-Item $transfer.FileName $backupPath -ErrorAction stop
					Write-Log ("[SUCCESS] Archive file: {0}" -f $transfer.FileName)
					}
					catch {
						$alertStatus = "1" 
						$alertMsg += "$(Get-Date  -UFormat '%Y-%m-%d %H:%M:%S') [ERROR] Failed to Archive File: {0}`n" -f $transfer.FileName
						Write-Log ("[ERROR] Archive failed: {0}" -f $transfer.FileName)
					}
					}
					else
					{
						$alertStatus = "1" 
						$alertMsg += "$(Get-Date  -UFormat '%Y-%m-%d %H:%M:%S') [ERROR] Failed to Upload File: {0}`n" -f $transfer.FileName
						Write-Log ("[ERROR] Upload Failed: {0}" -f $transfer.FileName, $transfer.Error.Message)
				}
			}
		}
		finally
		{
			# Disconnect, clean up
			$session.Dispose()
		}
 
		Write-Log ("[INFO] File Transfer Completed")
	}
	catch [Exception]
	{
		$alertStatus = "1" 
		$alertMsg += ("$(Get-Date  -UFormat '%Y-%m-%d %H:%M:%S') [ERROR] File Transfer system failed, error: `n{0}`n" -f $_.Exception.Message)
		Write-log ("[Error] File Transfer system failed: {0}" -f $_.Exception.Message)
	}

## Allow returning Alerts	
Set-Variable -Name alertStatus -Value $alertStatus -Scope 1
Set-Variable -Name alertMsg -Value $alertMsg -Scope 1
}

function processAlerts
{
	if(!($alertStatus -eq "0" )) {
		$alertnumber = $(echo $alertMsg | Measure-Object -Line  | Select-Object -expand Lines)
		Write-Log "[ERROR] $alertnumber Problem(s) were detected!!!"
		if(($mailAlerts -eq "1")) {
		Write-Log "[INFO] Attempting to send EMAIL alert"
			try {
				Send-MailMessage -From $mailFrom -to $mailTo -Subject "ABP Transfer Errors Detected -Project: $projectName" -Body $alertMsg -SmtpServer $mailServer
				Write-Log "[INFO] E-Mail Alert message queued to mail system..."
			}
			catch {
				Write-Log "[ERROR] E-Mail Alert message failed..."
			}
		} else {
		Write-Log "[INFO] Alert EMails are suppressed."
		}
	}
}


function HouseCleaning
{
	Write-Log "[MAINT] Starting House Cleaning..."
	$CurrentDate = Get-Date
	
	$logstoDelete = $CurrentDate.AddDays(-$daysLogs)
	Get-ChildItem $logFolder | Where-Object { $_.LastWriteTime -lt $logstoDelete } | Remove-Item
	
	$archivetoDelete = $CurrentDate.AddDays(-$daysArchive)
	Get-ChildItem $backupPath | Where-Object { $_.LastWriteTime -lt $archivetoDelete } | Remove-Item  
}

function Write-Log
{
	[cmdletbinding()]
	Param (
		$logdata
	)
	Write-Output "$(Get-Date -UFormat '%Y-%m-%d %H:%M:%S') $logdata" | Out-File -FilePath $logPath -Append
}

function start-Process
{
	# Before we start, lets make sure the log folder exists
	if(!(Test-Path -Path $logFolder )){
		New-Item -ItemType directory -Path $logFolder
		Write-Log "[WARN] Log Folder was missing on Start!!"
	}
	Write-Log "[START] Starting File Processing..."
}

function end-Process
{
	if (!($alertStatus -eq 0)) {
		$errCount = $(echo $alertMsg | Measure-Object -Line  | Select-Object -expand Lines)
		Write-Log "[END] Completed File Processing with $errCount errors!" 
	} else {
		Write-Log "[END] Completed File Processing."
	}
}

<#
Script logic, you can disable modiles by commenting them out below
Logging is called by ever module so do not disable it or you will break the dataflow
#>
start-Process
validate-Folders
select-Server
stage-Activefiles
transfer-Files
processAlerts
HouseCleaning
end-Process
