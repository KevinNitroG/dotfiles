@echo off
setlocal EnableDelayedExpansion

REM Get the current Wi-Fi SSID
set "ssid="
for /f "tokens=2 delims=: " %%a in ('netsh wlan show interfaces ^| find "SSID"') do (
    set "ssid=%%a"
    goto :break
)
:break

REM Check if the Wi-Fi SSID matches the specified names
if /i "!ssid!"=="TP-LINK_E85C" (
    call :run_curl
) else if /i "!ssid!"=="SonLam" (
    call :run_curl
) else if /i "!ssid!"=="iptime" (
    call :run_curl
) else if /i "!ssid!"=="iptime 5GHz" (
    call :run_curl
)

goto :eof

:run_curl
REM Run the curl command
curl "https://link-ip.nextdns.io/442fd8/18bf264a6c664704"
curl "https://www.duckdns.org/update?domains=kevinnitrohome.duckdns.org&token=1bd3467b-2cb9-4993-ac0b-19a98cc0903f&verbose=true"
goto :eof