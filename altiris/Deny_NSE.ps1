# Import the WebAdministration module to run following commands
Import-Module -Name WebAdministration

#### Get IIS Settings before update ###

# Get IP Address from IIS
$ipaddress = (get-WebConfiguration /system.webServer/security/ipSecurity/add -location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select ipAddress)
 
# Get AllowUnlisted value from IIS
$all_unlisted = (get-WebConfigurationProperty /system.webserver/security/ipsecurity -Name allowUnlisted -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select name,value)
$unlisted = (get-WebConfigurationProperty /system.webserver/security/ipsecurity -Name allowUnlisted -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select value)


### Set IIS to DENY new NSE files ###

# Add IP Address to IIS
if ($ipaddress -ne $null)
	{
	write-host "IP Address already set to: " $ipaddress
	}
	else
	{
	Add-WebConfiguration /system.webServer/security/ipSecurity -location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' -value @{ipAddress='127.0.0.1';allowed='true'} 
	}

# Set AllowUnlised to false
if($unlisted -like "*True*")
	{
	Set-WebConfigurationProperty -Filter /system.webserver/security/ipsecurity -Name allowUnlisted -Value False -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx'
	}

	

#### Get IIS Settings after Update ###	
	
# Get IP Address from IIS
$ipaddress = (get-WebConfiguration /system.webServer/security/ipSecurity/add -location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select ipAddress)
 
# Get AllowUnlisted value from IIS
$all_unlisted = (get-WebConfigurationProperty /system.webserver/security/ipsecurity -Name allowUnlisted -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select name,value)
$unlisted = (get-WebConfigurationProperty /system.webserver/security/ipsecurity -Name allowUnlisted -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select value)	
	
### Display IIS Settings ###	
	
# Output the results
if(($unlisted -like "*False*")-and ($ipaddress -ne $null))
	{
	write-host "AllUnlisted Value: " $all_unlisted
	write-host "IP Address: " $ipaddress
	write-host "`nIIS is set to DENY new NSE files"
	}
	else
	{
	write-host "AllUnlisted Value: " $all_unlisted
	write-host "IP Address: No IP Address set"
	write-host "`nSetting NOT Updated to DENY. Please try again or set manually"
	}