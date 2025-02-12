# TODO: Check if brave installed later

$regUrl = 'https://raw.githubusercontent.com/MulesGaming/brave-debullshitinator/refs/heads/main/brave_debullshitinator-policies.reg'
$regFile = New-TemporaryFile
Invoke-WebRequest -Uri $regUrl -OutFile $regFile.FullName
Start-Process reg -ArgumentList "import `"$($regFile.FullName)`"" -Wait -NoNewWindow
Remove-Item $regFile.FullName -Force
