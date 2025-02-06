if (Get-Command 'scoop')
{
  exit
}

Write-Host 'INSTALLING SCOOP...'

Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
