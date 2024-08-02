@echo off
set adserver=192.168.193.10
:loop
ping -n 1 %adserver% > nul
if errorlevel 1 (
    echo "AD NOT Pingable!!!"
    timeout /t 5
) else (
    echo "AD Pingable!!!"
    setlocal enabledelayedexpansion
    set logfile=\\%adserver%\c$\SharedDir\IOS-IT\ITDept\startupTest.log
    echo Attempting to log to: !logfile! >> nul
    echo ================================================ >> !logfile!
    echo =======================FromScript========================= >> !logfile!
    hostname >> !logfile!
    echo %date% %time% >> !logfile!
    echo ---------------------------------------------- >> !logfile!
    "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klmover.exe" -address outbound-wsus.ioscenterinc.local >> !logfile!
    echo ================================================ >> !logfile!
    endlocal
    exit
)
goto :loop
