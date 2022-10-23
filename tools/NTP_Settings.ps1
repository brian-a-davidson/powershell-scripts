# Get Current NTP Servers
$ntp_server1 = (Get-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers)."1"
$ntp_server2 = (Get-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers)."2"
$ntp_server3 = (Get-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers)."3"

# Display Current NTP Servers
echo "NTP Server 1 is currently set to: $ntp_server1"
echo "NTP Server 2 is currently set to: $ntp_server2"
echo "NTP Server 3 is currently set to: $ntp_server3"

# Display Update message
echo "** Now Updating the NTP Settings **"


# Update NTP Server 1
if ($ntp_server1 -like "time.windows.com")
	{
		echo "NTP server 1 is already set correctly"
	}
	else
	{
		Set-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers -Name "1" -Value "time.windows.com"
        $ntp_server1 = (Get-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers)."1"
        echo "NTP server 1 is now set to: $ntp_server1"
	}


# Update NTP Server 2
if ($ntp_server1 -like "time.nist.gov")
	{
		echo "NTP server 2 is already set correctly"
	}
	else
	{
		Set-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers -Name "2" -Value "time.nist.gov"
        $ntp_server2 = (Get-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers)."2"
        echo "NTP server 2 is now set to: $ntp_server2"
	}
    
# Update NTP Server 3
if ($ntp_server3 -like "time-nw-nist.gov")
	{
		echo "NTP server 3 is already set correctly"
	}
	else
	{
		Set-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers -Name "3" -Value "time-nw-nist.gov"
        $ntp_server3 = (Get-ItemProperty -Path hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers)."3"
        echo "NTP server 3 is now set to: $ntp_server3"
	}