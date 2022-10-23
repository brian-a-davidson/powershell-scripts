###############################################################################
# Name: ServerRoles.ps1
# Purpose: Configure Windows server roles for Altiris Site Servers
# Return Codes: '0' for success
#               '10' for .NET install failure
#               '20' for App or File Server install failure
#               '30' for IIS install failure
#               '40' for app pool configuration failure
# Change Log: (EB019510) Initial script adapted from 
#             http://www.symantec.com/connect/forums/iis-role-services-package-and-task-service-site-server
###############################################################################

#Import Server Manager and Web Administration Modules
Import-Module Servermanager,WebAdministration

# Display loaded modules
$modules = get-module -name Servermanager,WebAdministration | format-wide name -AutoSize
Write-output "The following modules have been loaded: " $modules


# Get server role list before 
get-windowsfeature | Out-File c:\temp\server_roles_before_install.txt

#Install .NET
Write-Host "Installing .NET"
Try
{
    Add-WindowsFeature NET-Framework -IncludeAllSubFeature
}
Catch [System.Exception] 
{
    $ex = $_.Exception
    Write-Host ".NET install failed:  " + $ex.Message
    Exit 10  
}

#Instal Application Server and File Server
Write-Host "Installing Application Server and File Server"
Try
{
    Add-WindowsFeature Application-Server, AS-NET-Framework, AS-Web-Support, AS-WAS-Support, AS-HTTP-Activation, AS-TCP-Activation, AS-Named-Pipes, File-Services, FS-FileServer
}
Catch [System.Exception] 
{
    $ex = $_.Exception
    Write-Host "App and File Server install failed:  " + $ex.Message 
    Exit 20
}

#Install IIS
Write-Host "Installing IIS"
Try
{
	Add-WindowsFeature Web-Server, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Http-Redirect, 
	Web-Asp-Net, Web-Net-Ext, Web-ASP, Web-ISAPI-Ext, Web-ISAPI-Filter,
	Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing,
	Web-Security, Web-Performance, Web-Mgmt-Tools,Web-Mgmt-Compat
}
Catch [System.Exception] 
{
    $ex = $_.Exception
    Write-Host "IIS install failed:  " + $ex.Message 
    Exit 30 
}                   

#Set the default app pool type to classic
Write-Host "Configuring Default Application pool"
Try
{
    Set-ItemProperty IIS:\AppPools\DefaultAppPool ManagedPipelineMode 1
	$mode = Get-ItemProperty IIS:\AppPools\DefaultAppPool -name ManagedPipelineMode
	Write-Host "The Default Application Pool is set to: " $mode
}
Catch [System.Exception] 
{
    $ex = $_.Exception
    Write-Host "Configuring app pool failed:  " + $ex.Message 
    Exit 40
} 

# Get server role list after
get-windowsfeature | Out-File c:\temp\server_roles_install.txt

Write-Host "Installation Log File: c:\temp\server_roles_install.txt"
Write-Host "Installation Complete.  Please reboot server."