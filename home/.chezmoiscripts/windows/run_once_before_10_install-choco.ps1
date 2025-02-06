if (Get-Command 'choco')
{
  Write-Host 'CHOCO ALREADY INSTALLED'
  exit
}

Write-Host 'INSTALLING CHOCO...'

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
