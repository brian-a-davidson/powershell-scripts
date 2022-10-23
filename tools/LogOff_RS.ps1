###############################################################################
# Name: LogOff_RS.ps1
# Purpose: Log off remote sessions
# Author: Brian Davidson
# Version: 1.0   
###############################################################################

function Get-Off 
{
	# Get server name
	$server=read-host "Server Name"

	# Create a session
	$session=New-PSsession -ComputerName $server

	# Check users on server
	invoke-command -session $session {qwinsta}

	# Find session id
	write-host "`n"
	[int]$sessionID=read-host "Which session id would you like to log off "

		function Get-Correct 
		{	
			# Ensure correct session
			$correct=read-host "Are you sure you want to logoff session #$sessionID (Y or N)"

			If ($correct -like "y"-or $correct -like "yes")
			{
				# Log off that session id
				logoff /server:$server $sessionID /v
			}
			elseif ($correct -like "n" -or $correct -like "no")
			{
				Remove-PSSession $server
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

	# Check users again
	write-host "`n"
	invoke-command -session $session {qwinsta}

	function Get-Rerun
	{
		$rerun=read-host "`nWould you like to log off a another remote session (Y or N)"

		If ($rerun -like "y"-or $rerun -like "yes")
		{
			Get-Off
		}
		elseif ($rerun -like "n" -or $rerun -like "no")
		{
			Remove-PSSession $server
			exit
		}
		else
		{
			write-warning "Must be yes or no answer"
			Get-ReRun
		}
	}
	# Run Get-Rerun Function
	Get-Rerun		
}




function Get-Run 
{
	$run=read-host "Would you like to log off a remote session (Y or N)"

	If ($run -like "y"-or $run -like "yes")
		{
		Get-Off
		}
	elseif ($run -like "n" -or $run -like "no")
		{
		exit
		}
	else
		{
		write-warning "Must be yes or no answer"
		Get-Run
		}
}

# Run Get-Run Function
Get-Run










