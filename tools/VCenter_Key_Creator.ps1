###############################################################################
# Name: Vcenter_Key_Creator.ps1
# Purpose: Create VCenter Keys 
# Author: Brian Davidson
# Version: 1.0   
###############################################################################

# Get Domain Name
$domain = read-host "Domain Name"

# Get Service Account Name
$svc = read-host "Service Account Name"

# Get Password
$pwd = read-host -assecurestring "Password"

# Send respsone to text file
write-output "$domain\$svc" | out-file c:\vCenter_Discovery\vCenter1.txt

# Send secure password to text file
$pwd | convertfrom-securestring | out-file c:\vCenter_Discovery\vCenter2.txt

# Create VC Key
$vcKey = (1,27,85,34,238,92,10,9,25,78,52,94,108,184,47,18)

# Send to text file
$vcKey | Set-Content C:\vCenter_Discovery\vcKey.txt

# Read in the secure file as a secure string
$my_secure_string = Get-Content c:\vCenter_Discovery\vCenter2.txt | ConvertTo-SecureString

# Save an encrypted string to a new file using our key and use this file in our script for vCenter credential object
$my_encrypted_string = ConvertFrom-SecureString $my_secure_string -key $vcKey | Set-Content C:\vCenter_Discovery\vCenter3.txt

write-output "The Vcenter Keys have been created!"






