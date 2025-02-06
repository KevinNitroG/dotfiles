$Path = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup", "komorerbi.lnk")

Test-Path $Path -PathType Leaf

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($Path)
$Shortcut.TargetPath = (Get-Command 'komorebic-no-console').Source
$Shortcut.Arguments = "start"
$Shortcut.Save()
