# What is this repository?
In 5/17 researchers found that HP included a Conexant Audio Driver with keylogging functionality on various laptop models between 2015 and then. The program has several artifacts, the existence of `C:\Windows\System32\MicTray.exe`, `C:\Windows\System32\MicTray64.exe`, and the keylog, if present, at `C:\Users\Public\MicTray.log`. This repository is a tool which detects the presence of the software or logfile on an individual machine or accross an ActiveDirectory Domain.

# About MicTray.exe
Technical Details about this issue can be found here: https://www.modzero.ch/advisories/MZ-17-01-Conexant-Keylogger.txt 

In summary, Conexant provided HP with an audio driver which, in order to detect special key combinations (to turn volume up/down, mute sound, and so forth), used a bad method where it tracks all keystrokes and some versions even log the output. This driver was distributed with many HP laptops (versions provided in the above link) since 2015 and was also distributed through the HP software/driver download pages.

# How does this tool work?

The script has two modes: Single Computer or Full Domain. The modes slightly change the execution of the script. 
The simplest mode is the single computer scan. In this mode, a single argument is provided to target that specific computer by IP or by Name. To execute, using an administrator account run the following from the directory the script is installed in: 
`./Get-MicTrayData –TargetHost <Hostname>`

The script then imports the ActiveDirectory module which is used to request computer information from AD. The script finds the specified computer objects and then does a for loop on the one system. First, the script tests if the system is online with the Test-Connection command, essentially a ping command in powershell. If the system responds the script will attempt an SMB connection with “Test-Path” to validate if files are in the following locations:
1)	C:\Windows\System32\MicTray.exe
2)	C:\Windows\System32\MicTray64.exe
3)	C:\Users\Public\MicTray.log

These files indicate one of two things:
1)	The driver is installed
2)	The driver is installed and a log file is present

Either of these should trigger a check to verify if the program has been patched and to manually delete the keylog file if present. In this case, one of 3 log files are generated:
`MicTrayVulnerable.txt`
`MicTraySafe.txt`
`MicTrayOffline.txt`
The first is generated if the .exe file is detected. The second if no .exe files are detected, and the last if the system doesn’t respond to a ping.

The second mode, full domain scan, is run by executing the script without any additional parameters. It runs the same as the above with the following differences.

Installed of using the `Get-ADComputer` command on an individual machine, the script imports all not-disabled systems in the AD Domain. It takes this list and iterates through them, running the same process of “Check if online”, “Check if log exists”, and then “Check if exe exists”. The results of these are logged in to the same 3 files as above with the hostname of the target systems.
Once complete, searching through the console output for ‘VULNERABLE’ or opening the MicTrayVulnerable.txt file will yield the machines with the driver installed. This, again, indicates to check that the latest patches have been installed and to clear out the log file if present.

# TODO
1) Add support for WMI or other mechanisms to check if updates which remove the risk have been applied to the remote systems.

# License

This project is licensed with the GNU General Public License v3.0. 
Use code at your own risk.
