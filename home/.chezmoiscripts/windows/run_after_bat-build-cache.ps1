if (-Not (Get-Command 'bat'))
{
  exit
}

Write-Host 'BUILDING BAT CACHE...'
bat cache --build
