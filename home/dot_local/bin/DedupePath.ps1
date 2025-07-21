Write-Host "This won't ensure the order of paths"

$Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User) -split ";"
$deduped = $Path | Select-Object -Unique
$newPath = $deduped -join ";"


[System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::User)
