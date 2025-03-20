# Installed via winget (msstore)
if (-not (Test-Path -Path "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application"))
{
  exit 0
}

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
}

Write-Host 'DEBLOATING BRAVE...'

$regUrl = 'https://raw.githubusercontent.com/MulesGaming/brave-debullshitinator/refs/heads/main/brave_debullshitinator-policies.reg'
$regFile = New-TemporaryFile
Invoke-WebRequest -Uri $regUrl -OutFile $regFile.FullName
reg import $regFile.FullName
Remove-Item $regFile.FullName -Force
