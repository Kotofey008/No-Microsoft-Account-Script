@echo off
setlocal
color 07
title OOBE Bypass Script
if not defined terminal mode 62, 26

net session >nul 2>&1
if %errorlevel% NEQ 0 (
  echo Administrator previleges are required.
  pause
  exit /b 1
)

:MainMenu
cls
echo.
echo        ================================================
echo                  OOBE BYPASS OPTIONS
echo        ================================================
echo.
echo        [1] BypassNRO (No Internet + restart)
echo           - Adds BypassNRO registry key and restarts
echo.
echo        [2] HideOnlineAccountScreens (With Internet)
echo           - Adds HideOnlineAccountScreens registry key
echo.
echo        [3] LocalOnly (Legacy)
echo           - Opens legacy local account creation
echo.
echo        [0] Exit
echo        ================================================
echo.
choice /C 1230 /N /M "Choose an option [1,2,3,0]: "

if %errorlevel% EQU 1 goto :BypassNRO
if %errorlevel% EQU 2 goto :HideOnlineAccountScreens
if %errorlevel% EQU 3 goto :LocalOnly
if %errorlevel% EQU 4 exit /b

:BypassNRO
echo.
echo Applying BypassNRO registry setting...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d 1 /f
if %errorlevel% EQU 0 (
    echo Successfully applied BypassNRO!
    echo.
    echo Computer will restart in 5 seconds...
    timeout /t 5 /nobreak >nul
    shutdown /r /t 0
) else (
    echo Failed to apply registry setting!
    pause
)
goto :MainMenu

:HideOnlineAccountScreens
echo.
echo Applying HideOnlineAccountScreens registry setting...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "HideOnlineAccountScreens" /t REG_DWORD /d 1 /f
if %errorlevel% EQU 0 (
    echo Successfully applied HideOnlineAccountScreens!
) else (
    echo Failed to apply registry setting!
)
echo.
pause
goto :MainMenu

:LocalOnly
echo.
echo Opening legacy local account creation...
start "" "ms-cxh:localonly"
echo.
echo Legacy local account screen should open...
pause
goto :MainMenu
