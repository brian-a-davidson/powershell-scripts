# Import the WebAdministration module to run following commands
Import-Module -Name WebAdministration 

#### Get IIS Settings before update ###

# Get IP Address from IIS
$ipaddress = (get-WebConfiguration /system.webServer/security/ipSecurity/add -location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select ipAddress)
 
# Get AllowUnlisted value from IIS
$all_unlisted = (get-WebConfigurationProperty /system.webserver/security/ipsecurity -Name allowUnlisted -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select name,value)
$unlisted = (get-WebConfigurationProperty /system.webserver/security/ipsecurity -Name allowUnlisted -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx' | select value)


### Set IIS to Allow new NSE files ###

# Remove IP Address from IIS
if ($ipaddress -ne $null)
	{
	clear-WebConfiguration /system.webServer/security/ipSecurity/add -location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx'
	}

# Set AllUnlisted property to True
if($unlisted -like "*False*")
	{
	Set-WebConfigurationProperty -Filter /system.webserver/security/ipsecurity -Name allowUnlisted -Value True -Location 'Default Web Site/Altiris/NS/Agent/PostEvent.aspx'
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
	write-host "`nSetting NOT Updated to Allow. Please try again or set manually"
	}
	else
	{
	write-host "AllUnlisted Value: " $all_unlisted
	write-host "IP Address: No IP Address set"
	write-host "`nIIS is set to ALLOW new NSE files"
	}