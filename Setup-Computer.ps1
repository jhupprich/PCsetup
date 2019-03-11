<#
  .SYNOPSIS
  Installs software and makes configuration changes

  .DESCRIPTION
   Run from an admin PowerShell console. Add configurations as needed, add or comment out 
   Chocolatey packages as needed. Script file will be deleted after running.

  .PARAMETER ComputerName
  Computer name name will be applied at reboot

  .EXAMPLE
  .\Setup-Computer 'CPU-001'

  .NOTES
  Configs:
  Names computer
  Sets time zone to AKST
  Turns off Windows firewalls
  Sets power config to 'always on'
  Adds local admin account
  Enables RDP
#>

param ($ComputerName) 

#set local admin. Edit this as needed
$pass = ConvertTo-SecureString "SomePassword" -AsPlainText -Force
$localAdmin = 'your admin account'

#name computer
Rename-Computer -NewName $ComputerName

#install Chocolatey
Set-ExecutionPolicy Unrestricted -Scope Process -Force; iex `
((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#install apps
#choco install LogMeIn -s "http://chocoserver.com" -y
choco install adobereader -y
choco install jre8 -y 
choco install flashplayerplugin -y
choco install silverlight -y
choco install googlechrome -y

#office 365 - uncomment the correct version
#choco install office365proplus -y
choco install office365business -y

#local admin - If you leave this in, make sure the username and password are correct on lines 20-21
New-LocalUser -Name $localAdmin -Password $pass -Description 'COIT local admin account' `
-PasswordNeverExpires -AccountNeverExpires
Add-LocalGroupMember -Member $localAdmin -Group 'Administrators'

#enable RDP
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) `
 | Out-Null
(Get-WmiObject -Class "Win32_TSGeneralSetting" `
 -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) `
 | Out-Null

#disable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

#set time zone
Set-TimeZone -Name 'Alaskan Standard Time'

#set power config to High Performance
#PowerCfg -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 
powercfg -change monitor -timeout-ac 0
powercfg -change monitor -timeout-dc 0
powercfg -change standby -timeout-ac 0
powercfg -change standby -timeout-dc 0

#reboot
Restart-Computer


