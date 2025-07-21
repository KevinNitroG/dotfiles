# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
}

Write-Host "IMPORTING TASK SCHEDULES..."

$pass = Read-Host "Enter `"$env:USERNAME`" password to import task schedules" -AsSecureString

$gettasks = Get-ChildItem -Path "$HOME\.config\windows-tasks-scheduler" -Filter "*.xml"

foreach ($task in $gettasks) {
  [xml]$gettask = Get-Content -Path $task.FullName
  $gettaskxmlstring = Get-Content -Path $task.FullName | Out-String
  $taskname = ($gettask.task.RegistrationInfo.URI).Split("\")[-1]

  Register-ScheduledTask -Xml $gettaskxmlstring -TaskName $taskname -TaskPath "\" -User $env:USERNAME -Password $pass
}
