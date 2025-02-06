if (Get-Command 'scoop')
{
  exit
}

Write-Host 'INSTALLING SCOOP...'

Import-Module Microsoft.PowerShell.Security
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
