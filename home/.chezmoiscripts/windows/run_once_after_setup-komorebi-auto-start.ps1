Write-Host "SETTING UP KOMOREBI AUTO START"

$Path = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup", "komorerbi.lnk")

if (Test-Path $Path -PathType Leaf)
{
  Write-Host "komorerbi shortcut is already created"
  exit
}

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($Path)
$Shortcut.TargetPath = (Get-Command 'komorebic-no-console').Source
$Shortcut.Arguments = "start"
$Shortcut.Save()
