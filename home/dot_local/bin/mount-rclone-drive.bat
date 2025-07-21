set PingWebsite=google.com
set TempDir=%TEMP%\rclone-mount
set LogFilePath=%TempDir%\log.txt
set RemoteName=CombineNeccessary
set DriveLetter=Z
set Counter=0

:CHECK_CONNECTION
ping %PingWebsite% -n 1 > nul
if %errorlevel% neq 0 (
    timeout /t 30 > nul
    set /a Counter+=1
    if %Counter% lss 5 (
        goto CHECK_CONNECTION
    ) else (
        exit 1
    )
)

IF NOT EXIST %TempDir% (
    mkdir %TempDir%
)

del /f /q %LogFilePath%

start SilentCMD rclone mount ^
    %RemoteName%: %DriveLetter%: ^
    --attr-timeout="1s" ^
    --buffer-size="512M" ^
    --bwlimit="40M" ^
    --cache-chunk-path=%TempDir%\chunks ^
    --cache-db-path=%TempDir%\db ^
    --cache-dir=%CacheDir% ^
    --cache-dir=%TempDir%\vfs ^
    --cache-info-age="60m" ^
    --cache-tmp-upload-path=%TempDir%\upload ^
    --cache-workers="8" ^
    --cache-writes ^
    --checkers="16" ^
    --dir-cache-time="60m" ^
    --drive-use-trash ^
    --ignore-checksum ^
    --log-file=%TempDir%\log.txt ^
    --max-read-ahead="128k" ^
    --metadata ^
    --network-mode ^
    --no-modtime ^
    --poll-interval="1m0s" ^
    --stats="0" ^
    --transfers="8" ^
    --vfs-cache-max-age="72h" ^
    --vfs-cache-max-size="off" ^
    --vfs-cache-mode=full ^
    --vfs-cache-poll-interval="1m0s" ^
    --vfs-read-chunk-size-limit="off" ^
    --vfs-read-chunk-size="128M" ^
    --volname="Cloud Storages"

timeout /t 2

taskkill /f /im SilentCMD.exe
