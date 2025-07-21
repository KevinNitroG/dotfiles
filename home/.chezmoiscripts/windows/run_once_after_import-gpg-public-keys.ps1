$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (-not (Get-Command "gpg" -ErrorAction SilentlyContinue))
{
  exit
}

curl 'https://github.com/web-flow.gpg' | gpg --import
