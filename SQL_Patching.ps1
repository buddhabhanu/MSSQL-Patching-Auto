param
(
    [parameter(Mandatory = $true)]
    [Alias("HostName", "SeverName")]
    [string[]] $ComputerName 
   # [parameter(Mandatory = $true)]
   # [Alias("CU", "PatchName", "ServicePack")]
   # [string] $CUName
)
$ServersNotReachable = @()

$ComputerName | ForEach-Object {

$count =Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue

If ($true -eq $count)
  {  
   $sql=Invoke-Sqlcmd -Server $server -Query 'set nocount on

create table #tab(Server_Name varchar(400),SQL_Instance varchar(400),Current_version varchar(Max))

insert into #tab 
select @@SERVERNAME as Server,@@SERVICENAME as SQLInstance,substring (@@VERSION,1,46) as Edition;

select *, case when Current_version like ''%2019%'' then ''5008996 Cumulative update 15 (CU15) for SQL Server 2019''
when Current_version like ''%2017%'' then ''5008084 Cumulative update 28 (CU28) for SQL Server 2017''
when Current_version like ''%2016%'' then ''5003279 Microsoft SQL Server 2016 Service Pack 3 (SP3)''
end as Prosed_patch
from #tab 
go
drop table #tab'
#To Display on screen
$sql
   
    #Check for the SQl server version and Pack details
    #$SQLInstance  = Get-SQLInstance -ComputerName $ComputerName -ErrorAction 'Stop'
   # $SQLInstance = Invoke-Sqlcmd -ServerInstance $ComputerName -Query "select @@SERVERNAME as Server,@@SERVICENAME as SQLInstance,substring (@@VERSION,1,54) as Edition;"
$SQL | out-file -Filepath C:\tmp\logs\Output.txt -Append
   


 #Check for the Pending Reboot on the list of Servers.
 Invoke-Command -ComputerName $ComputerName -ScriptBlock { 
     if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return 'Reboot Pending on ' +$true }
     if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return 'Reboot Pending on '+$true }
     if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return 'Reboot Pending on '+$true }
     try { 
       $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
       $status = $util.DetermineIfRebootPending()
       if(($status -ne $null) -and $status.RebootPending){
      # Wrtie-host $server
         return $true
       }
     }catch{}
 
     return $false

}


  }
       
else
    {
        $ServersNotReachable += $_ 
        Write-Host "The server(s) below is/are not reachable..." -ForegroundColor Red
        $ServersNotReachable
        
    }
}
