$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (-not (Get-Command "bat" -ErrorAction SilentlyContinue))
{
  exit
}

Write-Host 'BUILDING BAT CACHE...'
bat cache --build
