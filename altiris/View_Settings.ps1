# Import the WebAdministration module to run following commands
Import-Module -Name WebAdministration 

# Get IP Address from IIS
$ipaddress = (get-WebConfiguration /system.webServer/security/ipSecurity/add -location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select ipAddress)

# Get AllowUnlisted value from IIS
$all_unlisted = (get-WebConfigurationProperty /system.webserver/security/ipsecurity -Name allowUnlisted -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select name,value)
$unlisted = (get-WebConfigurationProperty /system.webserver/security/ipsecurity -Name allowUnlisted -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select value)

# Output the results
if(($unlisted -like "*False*")-and ($ipaddress -ne $null))
	{
	write-host "AllUnlisted Value: " $all_unlisted
	write-host "IP Address: " $ipaddress
	write-host "`nIIS is currently set to DENY new NSE files."
	}
	else
	{
	write-host "AllUnlisted Value: " $all_unlisted
	write-host "IP Address: No IP Address set"
	write-host "`nIIS is currently set to ALLOW new NSE files"
	}
	


