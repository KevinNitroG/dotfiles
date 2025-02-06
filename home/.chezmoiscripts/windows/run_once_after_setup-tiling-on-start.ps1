$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$NAME = 'tiling.lnk'
$scriptPath = "$HOME\.local\bin\start-tiling-window.bat"
$filePath = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup', $NAME)

if (Test-Path -Path $NAME -PathType Leaf)
{
  exit
}

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($filePath)
$Shortcut.TargetPath = (Get-Command "silentcmd.exe").Source
$Shortcut.Arguments = $scriptPath
$Shortcut.Save()
