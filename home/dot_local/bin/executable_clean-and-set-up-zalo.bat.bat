@REM >nul 2>&1 to direct output to none
net stop "zalo"
taskkill /im "zalo.exe" /f
taskkill /im "ZaloCall.exe" /f
taskkill /im "ZaloMeet.exe" /f
mkdir D:\ZaloPC
xcopy "%LocalAppData%\ZaloPC\" D:confused:ZaloPC /i /e
rmdir "%LocalAppData%\ZaloPC" /s /q
mklink /j "%LocalAppData%\ZaloPC\" "D:\ZaloPC"