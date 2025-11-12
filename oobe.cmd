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
echo        [4] Create user manually (experimental)
echo           - Creates a local account via commands
echo.
echo        [0] Exit
echo        ================================================
echo.
choice /C 12340 /N /M "Choose an option [1,2,3,4,0]: "

if %errorlevel% EQU 1 goto :BypassNRO
if %errorlevel% EQU 2 goto :HideOnlineAccountScreens
if %errorlevel% EQU 3 goto :LocalOnly
if %errorlevel% EQU 4 goto :CreateUser
if %errorlevel% EQU 5 exit /b

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

:CreateUser
echo.
echo ===========================
echo  Create user manually (experimental)
echo ===========================
set "USERNAME="
set /p "USERNAME=Enter new account name (no spaces recommended): "
if "%USERNAME%"=="" (
    echo Username cannot be empty. Returning to menu.
    pause
    goto :MainMenu
)

set "PASSWORD="
set /p "PASSWORD=Enter password (leave empty for no password): "

rem Ask whether to make the user an administrator. Validate input to accept only Y/y/N/n.
set "MAKEADMIN="
set /p "MAKEADMIN=Make user administrator? (Y/n) [default Y]: "
if "%MAKEADMIN%"=="" set "MAKEADMIN=Y"

:ValidateAdmin
rem Accept only Y/y/N/n. Loop until valid.
if /I "%MAKEADMIN%"=="Y" goto :AdminYes
if /I "%MAKEADMIN%"=="N" goto :AdminNo
echo.
echo Invalid input. Please enter Y or N.
set /p "MAKEADMIN=Make user administrator? (Y/n) [default Y]: "
if "%MAKEADMIN%"=="" set "MAKEADMIN=Y"
goto :ValidateAdmin

:AdminYes
echo.
if "%PASSWORD%"=="" (
    echo Creating user "%USERNAME%" with empty password...
    net user "%USERNAME%" "" /add
) else (
    echo Creating user "%USERNAME%"...
    net user "%USERNAME%" "%PASSWORD%" /add
)

if %errorlevel% NEQ 0 (
    echo Failed to create user "%USERNAME%".
    echo Make sure the account name is valid and you have administrator privileges.
    pause
    goto :MainMenu
)

echo Adding "%USERNAME%" to Administrators group...
rem Try English group name first, then try Russian group name as a fallback.
net localgroup "Administrators" "%USERNAME%" /add >nul 2>&1
if %errorlevel% NEQ 0 (
    net localgroup "Администраторы" "%USERNAME%" /add >nul 2>&1
)
goto :AfterCreate

:AdminNo
echo.
if "%PASSWORD%"=="" (
    echo Creating user "%USERNAME%" with empty password...
    net user "%USERNAME%" "" /add
) else (
    echo Creating user "%USERNAME%"...
    net user "%USERNAME%" "%PASSWORD%" /add
)

if %errorlevel% NEQ 0 (
    echo Failed to create user "%USERNAME%".
    echo Make sure the account name is valid and you have administrator privileges.
    pause
    goto :MainMenu
)

echo Creating standard user (not adding to Administrators)...
rem Attempt to remove from Administrators just in case it was added by default or by system policies.
net localgroup "Administrators" "%USERNAME%" /delete >nul 2>&1
net localgroup "Администраторы" "%USERNAME%" /delete >nul 2>&1
goto :AfterCreate

:AfterCreate
echo.
echo User "%USERNAME%" created successfully.
echo.

echo Computer will restart in 5 seconds to apply changes...
timeout /t 5 /nobreak >nul
::shutdown /r /t 0
pause
goto :MainMenu
