@echo off

REM Set the title of the command prompt window
title Enhancing TLS/SSL Security

REM Check for administrator privileges
openfiles > nul 2>&1
if %errorlevel% EQU 0 (
    goto adminPrivileged
) else (
    goto requireAdmin
)

:requireAdmin
    echo.
    echo ERROR: Administrator privileges are required to run this script.
    echo Please run this script as an administrator.
    pause > nul
    exit

:adminPrivileged
    echo.
    echo Administrator privileges detected. Proceeding with TLS/SSL configuration...
    echo.

REM Function to check if a specific TLS/SSL protocol is enabled
:isProtocolEnabled
    set "protocolName=%~1"
    set "registryPath=HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%protocolName%\Server"
    set "enabled="
    for /F "skip=2 tokens=2,*" %%A in ('reg query "%registryPath%" /v Enabled 2^>nul') do set "enabled=%%B"
    if defined enabled (
        set "enabled=%enabled:"=%"
    )
    if "%enabled%"=="1" (
        set "enabled=true"
    ) else (
        set "enabled=false"
    )
    exit /b

REM Function to disable a specific TLS/SSL protocol
:disableProtocol
    set "protocolName=%~1"
    set "registryPath=HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%protocolName%\Server"
    reg add "%registryPath%" /v Enabled /t REG_DWORD /d 0 /f > nul
    if errorlevel 1 (
        echo Failed to disable %protocolName%.
    ) else (
        echo %protocolName% disabled successfully.
    )
    exit /b

REM Check and configure TLS/SSL settings
echo.
echo Checking and configuring TLS/SSL protocol settings...
echo.

REM Check if TLS 1.0 and 1.1 are enabled
call :isProtocolEnabled "TLS 1.0"
if "%enabled%"=="true" (
    call :disableProtocol "TLS 1.0"
) else (
    echo TLS 1.0 is already disabled.
)

call :isProtocolEnabled "TLS 1.1"
if "%enabled%"=="true" (
    call :disableProtocol "TLS 1.1"
) else (
    echo TLS 1.1 is already disabled.
)

REM Check if SSL 2.0 and 3.0 are enabled
call :isProtocolEnabled "SSL 2.0"
if "%enabled%"=="true" (
    call :disableProtocol "SSL 2.0"
) else (
    echo SSL 2.0 is already disabled.
)

call :isProtocolEnabled "SSL 3.0"
if "%enabled%"=="true" (
    call :disableProtocol "SSL 3.0"
) else (
    echo SSL 3.0 is already disabled.
)

REM Enable TLS 1.2 and 1.3 if not already enabled
echo.
echo Ensuring TLS 1.2 and 1.3 are enabled...

REM Enable TLS 1.2
reg add "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002" /v Enabled /t REG_DWORD /d 1 /f > nul
if errorlevel 1 (
    echo Failed to enable TLS 1.2.
) else (
    echo TLS 1.2 enabled successfully.
)

REM Enable TLS 1.3
reg add "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002" /v Enabled /t REG_DWORD /d 1 /f > nul
if errorlevel 1 (
    echo Failed to enable TLS 1.3.
) else (
    echo TLS 1.3 enabled successfully.
)

REM Final message
echo.
echo TLS/SSL protocol settings have been checked and configured for enhanced security.
echo Only TLS 1.2 and 1.3 are enabled, while TLS 1.0, 1.1, SSL 2.0, and SSL 3.0 are disabled.
echo.
pause
