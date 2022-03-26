#This Script is to Patch the MSSQL Servers from a Remote centralized server.


#Execute Policy
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# To import the module of DBTOOLS offine from the path
Import-Module "C:\Program Files\WindowsPowerShell\Modules\dbatools\dbatools.psm1"

# To update the Patch build offline sheet.it contains all the SQL historical list like Versions, service packs, KB number.
# so plan to get the updated json file quarterly from the online url:https://dataplat.github.io/assets/dbatools-buildref-index.json
Update-DbaBuildReference -LocalFile "C:\Program Files\WindowsPowerShell\Modules\dbatools\dbatools-buildref-index.json"

#Set your respective Build\Patch which is the Latest to apply to the SQL Instance. Usally Set (n-1) and (n-2) patch details.
# So it will patch to it autmatically and will not go beyond it.
Get-DbaBuildReference -MajorVersion 2019 -CumulativeUpdate CU5 -Update

#create a list of servers that you want to patch
$ServerList = '5CG91913M0'
 
#create a credential to pass in to the Update-DbaInstance command; this will prompt for your password

[string]$Username='vccnet\bbuddha'
[string]$Userpassword='XXXXXXXX'
[securestring]$secStringpassword= ConvertTo-SecureString $Userpassword -AsPlainText -Force
[pscredential]$credobject= New-Object System.Management.Automation.PSCredential $Username,$secStringpassword
$cred=$credobject

#$cred

#$cred_load = Get-Credential 
 
#Set the version that you want to update to
$version = '2019RTMCU5'
 
#Start Patching! The -Restart option will allow it to restart the SQL Server as needed
Update-DbaInstance -ComputerName $ServerList -Path C:\patch_dumps\SQLSERVER\2019\RTM\CU5\ -Credential $cred -Version $version
