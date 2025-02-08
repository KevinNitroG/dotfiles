:CHECK_CONNECTION
ping google.com -n 1 > nul
if %errorlevel% neq 0 (
    timeout /t 30 > nul
    goto CHECK_CONNECTION
)

del /f "D:\My Apps\Other Softwares\Rclone\mount cloud storages log.txt"

start SilentCMD rclone mount CombineNeccessary: Z: --cache-dir "D:\Program Files\Rclone Cache" --vfs-cache-mode full --network-mode --volname "Cloud Storages" --checksum --buffer-size=512M --vfs-cache-max-age 72h --transfers 8 --log-file "D:\My Apps\Other Softwares\Rclone\mount cloud storages log.txt"

timeout /t 2

taskkill /f /im SilentCMD.exe