<# 
 .Synopsis
  Scans a domain or target host for presence of the following files: C:\Windows\System32\MicTray.exe, C:\Windows\System32\MicTray64.exe, and C:\Users\Public\MicTray.log. 
  
  These are indicators of a piece of software shipped on HP systems which provided keylogging functionality or of the keylog itself.
  
  This can take some time to run on a domain. Output is viewed in the console or in output files where the script was run.

 .Description
  Uses Get-ADComputer -Filter * to collect a list of systems in the environment. The script will then attempt to ping each system in the environment to determine if it is on or offline.
  
  If the system is offline, no checks are made, if the system is online, two checks are made; one for the log file, another for the application. 
  
  Detecting of the application or the log file should trigger cleaning the log file if a patch wasn't applied as well as either verifying the application is up to date or removing and replacing it. 
  
  Data is saved in MicTray*.txt files and is also presented in the PowerShell Interpreter.

  DISCLAIMER
  This script is provided AS IS without warranty or guarantees of any kind. Nth Generation further disclaims all implied warranties, including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall Nth Generation, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the script.

  ##NOTE##
  In testing, the scan has sometimes appeared to hang on Exchange DAG names which are registered in Get-ADComputer. It has always eventually proceeded beyong that point after a few minutes, we have noticed negligible network and network impact from the use of this script.

 .Parameter TargetHost
  Specifies a target host to test

 .Example
   Get-MicTrayData

 .Example
   Get-MicTrayData -TargetHost MyComputer1
#>
param([string]$TargetHost = "")

Import-Module ActiveDirectory

if ($TargetHost -ne "") {
    $Computers = Get-ADComputer $TargetHost
    }
else {
    $Computers = Get-ADComputer -Filter "Enabled -eq '$True'" 
    }

ForEach ($Computer in $Computers) {
    $Name = $Computer.Name
    $Online = (Test-Connection -ComputerName $Name -ErrorAction SilentlyContinue -Count 1).Statuscode
		if ($Online -eq 0) {
			if (Test-Path "\\$Name\C$\Users\Public\MicTray.log") {
			Write-Host "$Name Has a Keylog File!!!!"
		}
            else {
            Write-Host "$Name has no log file"
            }
			if ( (Test-Path "\\$Name\C$\Windows\System32\MicTray64.exe") -Or (Test-Path "\\$Name\C$\Windows\System32\MicTray.exe") ) {
			Write-Host "$Name IS VULNERABLE!!!!"
            Add-Content MicTrayVulnerable.txt "$Name has MicTray installed!`n"
		}
            else {
            Write-Host "$Name Does not have the software installed."
            Add-Content MicTraySafe.txt "$Name does not have MicTray installed!`n"
            }
	}
        else {
            Write-Host "$Name is offline"
            Add-Content MicTrayOffline.txt "$Name is offline, verify the system is online before scanning again.`n"
            }
}