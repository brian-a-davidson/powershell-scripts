###############################################################################
# Name: Uninstall_Altiris_Agent.ps1
# Purpose: Uninstall Altiris Agent 
# Author: Brian Davidson
# Version: 1.0   
###############################################################################


# Get server name
$server=read-host "Server Name"

# Create a session
$session=New-PSsession -ComputerName $server

# Check users on server
invoke-command -session $session {'"c:\program files\altiris\altiris agent\AeXNSAgent.exe" /uninstall /clean'}

# Run Uninstall Command
#invoke-command -computername $server {'"c:\program files\altiris\altiris agent\AeXNSAgent.exe" /uninstall /clean'}

