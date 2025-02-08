Write-Host "IMPORTING TASK SCHEDULES..."

$pass = Read-Host "Enter `"$env:USERNAME`" password to import task schedules" -AsSecureString

$gettasks = Get-ChildItem -Path "$HOME\.config\windows-tasks-scheduler" -Filter "*.xml"

foreach ($task in $gettasks) {
  [xml]$gettask = Get-Content -Path $task.FullName
  $gettaskxmlstring = Get-Content -Path $task.FullName | Out-String
  $taskname = ($gettask.task.RegistrationInfo.URI).Split("\")[-1]

  Register-ScheduledTask -Xml $gettaskxmlstring -TaskName $taskname -TaskPath "\" -User $env:USERNAME -Password $pass
}
