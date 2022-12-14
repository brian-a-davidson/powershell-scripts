#######################################################################################
#
# Altiris Install Script for Windows Servers
# Created On:  9/30/2014
# Adapted By:  BW022097 from PVS Altiris_GM_Install script maintained by Martin Becker (CWx Tech Imp)
# 
#======================================================================================
# Script designed to install Altiris with subagents
#
# Version 1.0 - BW022097 - 09/30/14 - Initial Adaptation
# Version 1.1 - BW022097 - 01/09/15 - Add Global and Client location installs
# Version 1.2 - BW022097 - 02/04/15 - Add logic for handling 32 vs 64 bit Software Management plugin install and forced delta inventories paths
#                                   - Add sleep after start of uninstall/install
#                                   - Add additional check for stopped processes: AexTemp, AexNSAgent
#								    _
# 
#######################################################################################

$ErrorActionPreference = "SilentlyContinue"
$Server = gc env:computername
$LogPath = "C:\Log_Files\"
$LogFile = $logPath+$Server+"_Altiris_Windows_Install.log"
$Bitness = (gwmi win32_OperatingSystem | select OSArchitecture) 

#if ($Bitness -match '64') 
#{	$SWAgent = "\nscap\bin\Win64\x64\Software Management\Plugin\SoftwareManagementSolution_Plugin_x64.msi'" 
#} 
#elseif ($Bitness -match '32') 
#{	$SWAgent = "\nscap\bin\Win32\X86\Software Management\Plugin\SoftwareManagementSolution_Plugin_x86.msi" 
#}

# Start Logging #
"$(Get-Date -f G) Altiris Install Script :  Info  : Altiris Install Started" | Out-File -FilePath $LogFile -Append
"$(Get-Date -f G) Altiris Install Script :  Info  : SERVER: $Server : : ARCHITECTURE: $BITNESS : USER: "+[Environment]::UserName | Out-File -FilePath $LogFile -Append
Write-Host "$(Get-Date -f G) Altiris Install Started" -ForegroundColor "Green"

Function AltirisKey
{   Set-ItemProperty -path "HKLM:\Software\Altiris\Altiris Agent" -name "Run UI in main session only" -value "1"   }

Function ProcessRunning ($Name)
{   $processCheck = $true
    $ticker = 6
    while($processCheck -eq $true -and $ticker -ge 0)
    {   
        $process = Get-Process -Name $Name
        if($process)
        {   "$(Get-Date -f G) Altiris Install Script :  Info  : $Name Started." | Out-File -FilePath $LogFile -Append 
            Write-Host "$(Get-Date -f G) $Name Started." -ForegroundColor "Green"
            $processCheck = $false        }
        else
        {   "$(Get-Date -f G) Altiris Install Script :  Info  : $Name Has Not Started. 10 Sec Sleep...." | Out-File -FilePath $LogFile -Append 
            Write-Host "$(Get-Date -f G) $Name Has Not Started. 10 Sec Sleep...." -ForegroundColor "Green"
            start-sleep -s 10
            $ticker - 1       }    }
    if($ticker -eq 0)
    {   "$(Get-Date -f G) Altiris Install Script :  Error  : $Name Failed to Start after 60 seconds.  Exiting." | Out-File -FilePath $LogFile -Append 
        Write-Host "$(Get-Date -f G) :  Error  : $Name Failed to Start after 60 seconds.  Exiting." -ForegroundColor "Red"
        "$(Get-Date -f G) Altiris Install Script :  Error  : Verify $Name exists and can run." | Out-File -FilePath $LogFile -Append
        Write-Host "$(Get-Date -f G) :  Error  : Verify $Name exists and can run." -ForegroundColor "Red"
        Exit 1    }    }

Function ProcessNotRunning ($Name2)
{   $processCheck = $true
    $ticker = 15
    while($processCheck -eq $true -and $ticker -ge 0)
    {   
        $process = Get-Process -Name $Name2
        if($process)
        {  "$(Get-Date -f G) Altiris Install Script :  Info  : $Name2 has not stopped yet. 10 Sec Sleep...." | Out-File -FilePath $LogFile -Append 
           Write-Host "$(Get-Date -f G) $Name2 has not stopped yet. 10 Sec Sleep...." -ForegroundColor "Green"
           start-sleep -s 10
           $ticker - 1    }
        else
        {  "$(Get-Date -f G) Altiris Install Script :  Info  : $Name2 has stopped. Continuing...." | Out-File -FilePath $LogFile -Append 
           Write-Host "$(Get-Date -f G) $Name2 has stopped. Continuing...." -ForegroundColor "Green"
           $processCheck = $false    }    }
    if($ticker -eq 0)
    {   "$(Get-Date -f G) Altiris Install Script :  Error  : $Name Failed to Stop after 2 minutes.  Exiting." | Out-File -FilePath $LogFile -Append 
        Write-Host "$(Get-Date -f G) :  Error  : $Name Failed to Stop after 2 minutes.  Exiting." -ForegroundColor "Red"
        "$(Get-Date -f G) Altiris Install Script :  Error  : Verify $Name process is not hung during uninstall." | Out-File -FilePath $LogFile -Append 
        Write-Host "$(Get-Date -f G) :  Error  : Verify $Name process is not hung during uninstall." -ForegroundColor "Red"
        Exit 1    }    }

$Location = read-host "Enter the datacenter in which your server resides and press 'OK'.  `nMatch exactly to one of the following choices - Global, Client, Corp, KC or LS"
# $CernerCMS = Get-ItemProperty -Path "hklm:\software\CernerCMS"
# $Location = $CernerCMS.Location

# If($Location.length -lt 1)
# {   "$(Get-Date -f G) Altiris Install Script :  Warn  : CernerCMS Location regkey not found, prompting for location." | Out-File -FilePath $LogFile -Append 
    # $Location = read-host "Server location not found.  Enter the datacenter in which your server resides.  Match exactly to one of the following choices - Corp, KC or LS"
    #Set-ItemProperty -path "HKLM:\software\Wow6432Node\CernerCMS" -name "Location" -value $Location
    # "$(Get-Date -f G) Altiris Install Script :  Info  : Location entered = $Location" | Out-File -FilePath $LogFile -Append
    # Write-Host "$(Get-Date -f G) Datacenter location entered: $Location" -ForegroundColor "Green"  }
# else
# {   "$(Get-Date -f G) Altiris Install Script :  Info  : Datacenter location found $Location" | Out-File -FilePath $LogFile -Append 
    # Write-Host "$(Get-Date -f G) Datacenter location found $Location" -ForegroundColor "Green"   }

#Uninstall any existing Altiris agent
Write-Host "$(Get-Date -f G) Cleaning up old Altiris install" -ForegroundColor "Green"
"$(Get-Date -f G) Altiris Install Script :  Info  : Altiris Uninstall Started to make sure server is clean." | Out-File -FilePath $LogFile -Append 
cmd /c 'c:\Program Files\Altiris\Altiris Agent\AeXNSAgent.exe' /uninstall

#Check to see the uninstall is finished
start-sleep -s 10
ProcessNotRunning AeXAgentUtil
ProcessNotRunning AexNSAgent
ProcessNotRunning AexTemp

#Clean Altiris folders and keys
#Write-Host "$(Get-Date -f G) Cleaning registry and folders/files." -ForegroundColor "Green"
#"$(Get-Date -f G) Altiris Install Script :  Info  : Cleaning registry and folders/files." | Out-File -FilePath $LogFile -Append
#Remove-Item "C:\Program Files\Altiris\*" -Recurse -Force
#Remove-Item "C:\Program Files (x86)\Altiris\*" -Recurse -Force
#Remove-Item "C:\ProgramData\Symantec\Symantec Agent\*" -Recurse -Force

#Modify registry to allow installation of subagents silently - adding .msi to key 'LowRiskFileTypes'
New-Item -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -name Associations
Set-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" -name "LowRiskFileTypes" -value ".exe;.bat;.reg;.vbs;.cmd;.ps1;.msi"

#Install New Agent Depending on DC Location
if($Location -like "*KC*")
{
    #Agent Install
    Write-Host "$(Get-Date -f G) Installing Altiris" -ForegroundColor "Green"
    "$(Get-Date -f G) Altiris Install Script :  Info  : Altiris Install Started for KC." | Out-File -FilePath $LogFile -Append
    $cmdaltKCinstall = { \\cernisaltns113.cernerasp.com\nscap\bin\Win32\X86\"NS Client Package"\aexnsc.exe -s -a ns=cernisaltns113.cernerasp.com nsweb=http://cernisaltns113.cernerasp.com/altiris/ NOSTARTMENU NOTRAYICON /s }
    Invoke-Command $cmdaltKCinstall
    
    #Check to see the install is finished
    start-sleep -s 10
    ProcessRunning AeXNSAgent
    
    #Modify registry to prevent spawning separate Altiris process for each logged on user - add dword value
    AltirisKey

    cmd /c 'C:\Program Files\Altiris\Altiris Agent\aexagentutil.exe' /SendBasicInventory

    #Install SubAgents
    "$(Get-Date -f G) Altiris Install Script :  Info  : Altiris SubAgents Install Started for KC." | Out-File -FilePath $LogFile -Append 
    Write-Host "$(Get-Date -f G) Installing SoftwareManagementSolution_Plugin" -ForegroundColor "Green"
    
    if ($Bitness -match '64') {	
        cmd /c '\\cernisaltns113.cernerasp.com\nscap\bin\Win64\x64\Software Management\Plugin\SoftwareManagementSolution_Plugin_x64.msi'
    } 
    elseif ($Bitness -match '32') {	
        cmd /c '\\cernisaltns113.cernerasp.com\nscap\bin\Win32\X86\Software Management\Plugin\SoftwareManagementSolution_Plugin_x86.msi'
    }
    else {
        "$(Get-Date -f G) Altiris Install Script :  Error  : Altiris SubAgents Install failed for KC.  Unable to determine OS architecture." | Out-File -FilePath $LogFile -Append
        Write-Host "$(Get-Date -f G) Altiris Install Script :  Error  : Altiris SubAgents Install failed for KC.  Unable to determine OS architecture." -ForegroundColor "Red"
        Exit 3
    }
    
    Write-Host "$(Get-Date -f G) Installing Symantec_InventoryAgent" -ForegroundColor "Green"
    cmd /c '\\cernisaltns113.cernerasp.com\nscap\bin\Win32\X86\Inventory\Agent Package\Symantec_InventoryAgent_x86.msi'
    Write-Host "$(Get-Date -f G) Installing ServerInventoryAgent" -ForegroundColor "Green"
    cmd /c '\\cernisaltns113.cernerasp.com\nscap\bin\Win32\X86\Server Inventory\Agent Package\Symantec_ServerInventoryAgent_x86.msi'
}
elseif($Location -like "*LS*")
{
    #Agent Install
    Write-Host "$(Get-Date -f G) Installing Altiris" -ForegroundColor "Green"
    "$(Get-Date -f G) Altiris Install Script :  Info  : Altiris Install Started for LS." | Out-File -FilePath $LogFile -Append
    $cmdaltLSinstall = { \\cernisaltns102.cernerasp.com\nscap\bin\Win32\X86\"NS Client Package"\aexnsc.exe -s -a ns=cernisaltns102.cernerasp.com nsweb=http://cernisaltns102.cernerasp.com/altiris/ NOSTARTMENU NOTRAYICON /s }
    Invoke-Command $cmdaltLSinstall
    
    #Check to see the install is finished
    start-sleep -s 10
    ProcessRunning AeXNSAgent
    
    #Modify registry to prevent spawning separate Altiris process for each logged on user - add dword value
    AltirisKey

    cmd /c 'C:\Program Files\Altiris\Altiris Agent\aexagentutil.exe' /SendBasicInventory

    #Install SubAgents
    "$(Get-Date -f G) Altiris Install Script :  Info  : Altiris SubAgents Install Started for LS." | Out-File -FilePath $LogFile -Append 
    Write-Host "$(Get-Date -f G) Installing SoftwareManagementSolution_Plugin" -ForegroundColor "Green"
    
    if ($Bitness -match '64') {	
        cmd /c '\\cernisaltns102.cernerasp.com\nscap\bin\Win64\x64\Software Management\Plugin\SoftwareManagementSolution_Plugin_x64.msi'
    } 
    elseif ($Bitness -match '32') {	
        cmd /c '\\cernisaltns102.cernerasp.com\nscap\bin\Win32\X86\Software Management\Plugin\SoftwareManagementSolution_Plugin_x86.msi'
    }
    else {
        "$(Get-Date -f G) Altiris Install Script :  Error  : Altiris SubAgents Install failed for LS.  Unable to determine OS architecture." | Out-File -FilePath $LogFile -Append
        Write-Host "$(Get-Date -f G) Altiris Install Script :  Error  : Altiris SubAgents Install failed for LS.  Unable to determine OS architecture." -ForegroundColor "Red"
        Exit 3
    }
    
    Write-Host "$(Get-Date -f G) Installing Symantec_InventoryAgent" -ForegroundColor "Green"
    cmd /c '\\cernisaltns102.cernerasp.com\nscap\bin\Win32\X86\Inventory\Agent Package\Symantec_InventoryAgent_x86.msi'
    Write-Host "$(Get-Date -f G) Installing ServerInventoryAgent" -ForegroundColor "Green"
    cmd /c '\\cernisaltns102.cernerasp.com\nscap\bin\Win32\X86\Server Inventory\Agent Package\Symantec_ServerInventoryAgent_x86.msi'
}
elseif($Location -like "*Corp*")
{
    #Agent Install
    Write-Host "$(Get-Date -f G) Installing Altiris" -ForegroundColor "Green"
    "$(Get-Date -f G) Altiris Install Script :  Info  : Altiris Install Started for Corp." | Out-File -FilePath $LogFile -Append
    $cmdaltCORPinstall = { \\cernisaltns121.northamerica.cerner.net\nscap\bin\Win32\X86\"NS Client Package"\aexnsc.exe -s -a ns=cernisaltns121.northamerica.cerner.net nsweb=http://cernisaltns121.northamerica.cerner.net/altiris/ NOSTARTMENU NOTRAYICON /s }
    Invoke-Command $cmdaltCORPinstall
    
    #Check to see the install is finished
    start-sleep -s 10
    ProcessRunning AeXNSAgent
    
    #Modify registry to prevent spawning separate Altiris process for each logged on user - add dword value
    AltirisKey

    cmd /c 'C:\Program Files\Altiris\Altiris Agent\aexagentutil.exe' /SendBasicInventory

    #Install SubAgents
    "$(Get-Date -f G) Altiris Install Script :  Info  : Altiris SubAgents Install Started for Corp." | Out-File -FilePath $LogFile -Append 
    Write-Host "$(Get-Date -f G) Installing SoftwareManagementSolution_Plugin" -ForegroundColor "Green"
    
    if ($Bitness -match '64') {	
        cmd /c '\\cernisaltns121.northamerica.cerner.net\nscap\bin\Win64\x64\Software Management\Plugin\SoftwareManagementSolution_Plugin_x64.msi'
    } 
    elseif ($Bitness -match '32') {	
        cmd /c '\\cernisaltns121.northamerica.cerner.net\nscap\bin\Win32\X86\Software Management\Plugin\SoftwareManagementSolution_Plugin_x86.msi'
    }
    else {
        "$(Get-Date -f G) Altiris Install Script :  Error  : Altiris SubAgents Install failed for Corp.  Unable to determine OS architecture." | Out-File -FilePath $LogFile -Append
        Write-Host "$(Get-Date -f G) Altiris Install Script :  Error  : Altiris SubAgents Install failed for Corp.  Unable to determine OS architecture." -ForegroundColor "Red"
        Exit 3
    }
    
    Write-Host "$(Get-Date -f G) Installing Symantec_InventoryAgent" -ForegroundColor "Green"
    cmd /c '\\cernisaltns121.northamerica.cerner.net\nscap\bin\Win32\X86\Inventory\Agent Package\Symantec_InventoryAgent_x86.msi'
    Write-Host "$(Get-Date -f G) Installing ServerInventoryAgent" -ForegroundColor "Green"
    cmd /c '\\cernisaltns121.northamerica.cerner.net\nscap\bin\Win32\X86\Server Inventory\Agent Package\Symantec_ServerInventoryAgent_x86.msi'
}
elseif($Location -like "*Client*" -or $Location -like "*Global*")
{
    #Agent Install
    Write-Host "$(Get-Date -f G) Installing Altiris" -ForegroundColor "Green"
    "$(Get-Date -f G) Altiris Install Script :  Info  : Altiris Install Started for Client or Global server." | Out-File -FilePath $LogFile -Append
    $cmdalt101install = { \\cernisaltns101.cernerasp.com\nscap\bin\Win32\X86\"NS Client Package"\aexnsc.exe -s -a ns=cernisaltns101.cernerasp.com nsweb=http://cernisaltns101.cernerasp.com/altiris/ NOSTARTMENU NOTRAYICON /s }
    Invoke-Command $cmdalt101install
    
    #Check to see the install is finished
    start-sleep -s 10
    ProcessRunning AeXNSAgent
    
    #Modify registry to prevent spawning separate Altiris process for each logged on user - add dword value
    AltirisKey

    cmd /c 'C:\Program Files\Altiris\Altiris Agent\aexagentutil.exe' /SendBasicInventory

    #Install SubAgents
    "$(Get-Date -f G) Altiris Install Script :  Info  : Altiris SubAgents Install Started for Client or Global server." | Out-File -FilePath $LogFile -Append 
    Write-Host "$(Get-Date -f G) Installing SoftwareManagementSolution_Plugin" -ForegroundColor "Green"
    
    if ($Bitness -match '64') {	
        cmd /c '\\cernisaltns101.cernerasp.com\nscap\bin\Win64\x64\Software Management\Plugin\SoftwareManagementSolution_Plugin_x64.msi'
    } 
    elseif ($Bitness -match '32') {	
        cmd /c '\\cernisaltns101.cernerasp.com\nscap\bin\Win32\X86\Software Management\Plugin\SoftwareManagementSolution_Plugin_x86.msi'
    }
    else {
        "$(Get-Date -f G) Altiris Install Script :  Error  : Altiris SubAgents Install failed for Client or Global.  Unable to determine OS architecture." | Out-File -FilePath $LogFile -Append
        Write-Host "$(Get-Date -f G) Altiris Install Script :  Error  : Altiris SubAgents Install failed for Client or Global.  Unable to determine OS architecture." -ForegroundColor "Red"
        Exit 3
    }
    
    Write-Host "$(Get-Date -f G) Installing Symantec_InventoryAgent" -ForegroundColor "Green"
    cmd /c '\\cernisaltns101.cernerasp.com\nscap\bin\Win32\X86\Inventory\Agent Package\Symantec_InventoryAgent_x86.msi'
    Write-Host "$(Get-Date -f G) Installing ServerInventoryAgent" -ForegroundColor "Green"
    cmd /c '\\cernisaltns101.cernerasp.com\nscap\bin\Win32\X86\Server Inventory\Agent Package\Symantec_ServerInventoryAgent_x86.msi'
}
else
{
	"$(Get-Date -f G) Altiris Install Script :  Info  : Unable to determine server location.  Installation will exit." | Out-File -FilePath $LogFile -Append 
    Write-Host "$(Get-Date -f G) Unable to determine server location.  Installation will exit." -ForegroundColor "Red"
	Exit 2
}

if ($Bitness -match '64') {
	#Force Inventory Updates 64-bit
	"$(Get-Date -f G) Altiris Install Script :  Info  : Kicking Off Delta Inventories." | Out-File -FilePath $LogFile -Append
	#Delta Hardware
	Write-Host "$(Get-Date -f G) Delta Hardware Inventory Started" -ForegroundColor "Green"
	"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Hardware Inventory Started." | Out-File -FilePath $LogFile -Append 
	cmd /c 'c:\Program Files (x86)\Altiris\Altiris Agent\Agents\Inventory Agent\InvSoln.exe' /dhi
	"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Hardware Inventory Complete." | Out-File -FilePath $LogFile -Append
	#Delta Software
	#Write-Host "$(Get-Date -f G) Delta Software Inventory Started" -ForegroundColor "Green"
	#"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Software Inventory Started." | Out-File -FilePath $LogFile -Append 
	#cmd /c 'c:\Program Files (x86)\Altiris\Altiris Agent\Agents\Inventory Agent\InvSoln.exe' /dswi
	#"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Software Inventory Complete." | Out-File -FilePath $LogFile -Append
	#Delta Server
	Write-Host "$(Get-Date -f G) Delta Server Inventory Started" -ForegroundColor "Green"
	"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Server Inventory Started." | Out-File -FilePath $LogFile -Append 
	cmd /c 'c:\Program Files (x86)\Altiris\Altiris Agent\Agents\Inventory Agent\InvSoln.exe' /dsi
	"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Server Inventory Complete." | Out-File -FilePath $LogFile -Append
}
elseif ($Bitness -match '32') {
	#Force Inventory Updates 32-bit
	"$(Get-Date -f G) Altiris Install Script :  Info  : Kicking Off Delta Inventories." | Out-File -FilePath $LogFile -Append
	#Delta Hardware
	Write-Host "$(Get-Date -f G) Delta Hardware Inventory Started" -ForegroundColor "Green"
	"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Hardware Inventory Started." | Out-File -FilePath $LogFile -Append 
	cmd /c 'c:\Program Files\Altiris\Altiris Agent\Agents\Inventory Agent\InvSoln.exe' /dhi
	"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Hardware Inventory Complete." | Out-File -FilePath $LogFile -Append
	#Delta Software
	#Write-Host "$(Get-Date -f G) Delta Software Inventory Started" -ForegroundColor "Green"
	#"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Software Inventory Started." | Out-File -FilePath $LogFile -Append 
	#cmd /c 'c:\Program Files\Altiris\Altiris Agent\Agents\Inventory Agent\InvSoln.exe' /dswi
	#"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Software Inventory Complete." | Out-File -FilePath $LogFile -Append
	#Delta Server
	Write-Host "$(Get-Date -f G) Delta Server Inventory Started" -ForegroundColor "Green"
	"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Server Inventory Started." | Out-File -FilePath $LogFile -Append 
	cmd /c 'c:\Program Files\Altiris\Altiris Agent\Agents\Inventory Agent\InvSoln.exe' /dsi
	"$(Get-Date -f G) Altiris Install Script :  Info  : Delta Server Inventory Complete." | Out-File -FilePath $LogFile -Append
	#Install Script Complete
	"$(Get-Date -f G) Altiris Install Script :  Info  : Altiris Installation Completed Successfully." | Out-File -FilePath $LogFile -Append 
	Write-Host "$(Get-Date -f G) Altiris Installation Completed Successfully." -ForegroundColor "Green"
}
else {
	Write-Host "$(Get-Date -f G) Unable to determine path for InvSoln.exe.  Delta inventory not sent." -ForegroundColor "Green"
	"$(Get-Date -f G) Altiris Install Script :  Info  : Unable to determine path for InvSoln.exe.  Delta inventory not sent." | Out-File -FilePath $LogFile -Append
}

