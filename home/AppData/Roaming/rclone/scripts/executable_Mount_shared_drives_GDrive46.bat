:CHECK_CONNECTION
ping google.com -n 1 > nul
if %errorlevel% neq 0 (
    timeout /t 5 > nul
    goto CHECK_CONNECTION
)

start SilentCMD rclone mount AllDrives: Y: --cache-dir "D:\Program Files\Rclone Cache" --vfs-cache-mode full --network-mode --volname "Shared Drives 46" --no-modtime --no-checksum --buffer-size=512M --vfs-cache-max-age 72h --config "D:/My Apps/Other Softwares/Rclone/rclone_shared_drive.conf" --vfs-disk-space-total-size 1P

timeout /t 2

taskkill /f /im SilentCMD.exe