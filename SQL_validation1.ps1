param (
[Parameter(Mandatory=$true)]
[string]$server
)
$SERVER=$server
function getSQLInstanceOnServer ([string]$SERVER) {
$services = Get-Service -Computer $SERVER
$services = $services | ? DisplayName -like "SQL Server (*)"
try {
$instances = $services.Name | ForEach-Object {($_).Replace("MSSQL`$","")}
}catch{
# if no instances are found return
return -1
}

return $instances
}
$sql1=getSQLInstanceOnServer $SERVER

$server1=$env:COMPUTERNAME +'\'+ $sql1
#$server1

Invoke-Sqlcmd -Server $server1 -Query 'set nocount on

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