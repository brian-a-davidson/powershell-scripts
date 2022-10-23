###############################################################################
# Name: Reboot_Server.ps1
# Purpose: Reboot Server Remotely 
# Author: Brian Davidson
# Version: 1.0   
###############################################################################

function Restart-Comp 
{
	# Get server name
	$server=read-host "Server Name"

		function Get-Correct 
		{	
			# Ensure correct server
			$correct=read-host "Are you sure you want to reboot $server (Y or N)"

			If ($correct -like "y"-or $correct -like "yes")
			{
				# Log off that session id
				restart-computer $server -confirm -force
			}
			elseif ($correct -like "n" -or $correct -like "no")
			{
				exit
			}
				else
			{
				write-warning "Must be yes or no answer"
				Get-Correct
			}
		}	

	# Run Get-Correct Function
	Get-Correct			
}

#Run Restart-Comp Function
Restart-Comp









