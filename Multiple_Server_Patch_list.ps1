Clear-Content -path "C:\tmp\Output.txt"



FOREACH($server in GC "C:\tmp\ServerList.txt")
 {
	invoke-expression -Command "&'C:\tmp\SQL_Patching.ps1' -ComputerName $server "  
 }
 write-host "Please verify the output for the details" -ForegroundColor Green
 write-host "Location: C:\tmp\Output.txt " -ForegroundColor Yellow
