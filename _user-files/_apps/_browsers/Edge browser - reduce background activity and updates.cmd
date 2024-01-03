@echo off

for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CONTROLSET001\CONTROL\NLS\Language" /v Installlanguage') do set UILanguage=%%a
call :CheckTranslastionFileAvailable

if %UILanguage%==0419 (
	chcp 1251 >nul 2>&1
) else (
	chcp 65001 >nul 2>&1
)

rem program version in cmd window title
call :SetWindowTitle 2

>nul 2>&1 2>&1 REG QUERY "HKU\S-1-5-19" ||(
	echo.
	call :PrintLineNum 5
 	echo.
	pause >nul 2>&1
	pause
	goto :eof
)

for /f "tokens=3" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Features" /V "TamperProtection" ^|findstr /ri "REG_DWORD"') do set RegValue=%%a
if %RegValue%==0x2 goto :start
if %RegValue%==0x4 goto :start

@echo.
call :PrintLineNum 42
call :PrintLineNum 43
call :PrintLineNum 44
call :PrintLineNum 45
@echo.
call :PrintLineNum 46
@echo.
@echo.
pause

:start
cls

@echo.
@echo.
call :PrintLineNum 161
call :PrintLineNum 162
call :PrintLineNum 163
@echo.
call :PrintLineNum 164
call :PrintLineNum 165
call :PrintLineNum 166
call :PrintLineNum 167
@echo.
@echo.
pause >nul 2>&1
pause

for /F "tokens=2" %%i in ('whoami /user /fo table /nh') do set usersid=%%i

cls
@echo.
call :PrintLineNum 10
%SystemRoot%\System32\CScript.exe "..\..\..\_tools\_apps\create-restore-point\create-restore-point.vbs"
rem waiting 6 seconds for restore point creation in background
ping localhost -n 6 >nul 2>&1

rem deploying additional Group Policy applets from Microsoft
if not exist %SystemDrive%\Windows\PolicyDefinitions\msedge.admx (
	xcopy "..\..\..\_tools\_apps\lgpo\Microsoft-Edge-additional-Group-Policy-applets\*.*" "%SystemDrive%\Windows\PolicyDefinitions\" /S/E/F/Y >nul 2>&1
)

rem Edge will not automatically install or update (only manual install/update allowed)
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "InstallDefault" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "Update{0D50BFEC-CD6A-4F9A-964C-C7416E3ACB10}" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "Update{2CD8A007-E189-409D-A2C8-9AF4EF3C72AA}" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "Update{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "Update{65C35B14-6C1D-4122-AC46-7148CC9D6497}" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdateDefault" /t REG_DWORD /d "2" /f >nul 2>&1

rem Edge browser won't autorun and don't stay background, but will work fine as usual
reg delete "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Run" /v "MicrosoftEdgeAutoLaunch_A3CC50A79E93F93E85E4D5B0A706CA88" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "AllowPrelaunch" /t REG_DWORD /d "0" /f >nul 2>&1

reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Dsh" /v IsPrelaunchEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}\Commands\on-logon-autolaunch" /v  AutoRunOnLogon /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}\Commands\on-logon-startup-boost" /v AutoRunOnLogon /t REG_DWORD /d 0 /f >nul 2>&1

rem MS Edge Browser - disable sticky confirmation about experience personilization
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "PersonalizationReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
rem MS Edge Browser - disable "Follow Creators" feature popups
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "EdgeFollowEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
rem MS Edge Browser - don't re-create shortcut on desktop after each update 
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d "0" /f >nul 2>&1
rem MS Edge Browser - disable user feedback
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "UserFeedback" /t REG_DWORD /d "0" /f >nul 2>&1
rem remove Edge shortcut
del /f /q "C:\Users\Public\Desktop\Microsoft Edge.lnk" >nul 2>&1

gpupdate /force >nul 2>&1

@echo.
@echo.
call :PrintLineNum 6
call :PrintLineNum 7
@echo.

@echo.
if [%1]==[] pause
exit /b

:PrintLineNum
set LineNum=%1
set /a LineNum-=1
for /f "usebackq delims=" %%a in (`more +%LineNum% "..\..\..\_translations\messages_%UILanguage%.txt"`) do (
	echo %%a
	exit /b
)

:SetWindowTitle
set LineNum=%1
set /a LineNum-=1
for /f "usebackq delims=" %%a in (`more +%LineNum% "..\..\..\_translations\messages_%UILanguage%.txt"`) do (
	title %%a
	exit /b
)


:CheckTranslastionFileAvailable
rem set English language if language file was not found
if not exist "..\..\..\_translations\messages_%UILanguage%.txt" (
	set UILanguage=0409
)
:eof
exit /b