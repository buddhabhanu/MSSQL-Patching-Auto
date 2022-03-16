param
(
    [parameter(Mandatory = $true)]
    [Alias("HostName", "SeverName")]
    [string[]] $ComputerName ,
    [parameter(Mandatory = $true)]
    [Alias("ver", "sqlversion")]
    [string[]] $version ,
    [parameter(Mandatory = $true)]
    [Alias("CU", "PatchName", "ServicePack")]
    [string] $CUName
)

$ExtractionPath     = 'C:\tmp\extract\'
$InstallerPath      = "C:\tmp\sqlserver$version-$CUName.exe"
$InstallerPath
$Arguments          = "/extract:`"$ExtractionPath`" /quiet"
$SuccessReturnCodes = @(0, 3010)

$Installer = (Get-Item $InstallerPath).FullName

If ($Installer) {
  $Params = @{
    'ComputerName' = $ComputerName  
  }

  $Params.ScriptBlock = {
    Try {
      $processStartInfo           = New-Object System.Diagnostics.ProcessStartInfo
      $processStartInfo.FileName  = $Using:InstallerPath
      $processStartInfo.Arguments = $Using:Arguments

      # Necessary for Windows Core Installs
      $processStartInfo.UseShellExecute = $false
      
      $process           = New-Object System.Diagnostics.Process
      $process.StartInfo = $processStartInfo
      
      $null = $process.Start()
      $process.WaitForExit()
            
      If ($process.ExitCode -NotIn $Using:SuccessReturnCodes) {
        Throw "Error running program: $($process.ExitCode)"
      }
    } Catch {
      Write-Error $_.Exception.ToString()
    }
  }

  $InstallResult = Invoke-Command @Params

  If ($InstallResult) {
    Restart-Computer -ComputerName $ComputerName -Wait -Force
  }
} Else {
  Throw "Installer not found"
}