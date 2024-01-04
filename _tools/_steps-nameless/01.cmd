@echo off

for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CONTROLSET001\CONTROL\NLS\Language" /v Installlanguage') do set UILanguage=%%a
call :CheckTranslastionFileAvailable

if %UILanguage%==0419 (
	chcp 1251 >nul 2>&1
) else (
	chcp 65001 >nul 2>&1
)

@echo.
call :PrintLineNum 4
@echo.
systeminfo | findstr /i /c:"windows 11" > nul && set Windows=11 || set Windows=10
cls
if not %Windows%==11 (
	@echo.
	call :PrintLineNum 12
	@echo.
	if [%1]==[] pause
	goto :eof
)

rem program version in cmd window title
call :SetWindowTitle 2

>NUL 2>&1 REG QUERY "HKU\S-1-5-19" ||(
	echo.
	call :PrintLineNum 5
 	echo.
	pause >nul
	pause
	goto :eof
)



@echo.
call :PrintLineNum 86
@echo.
call :PrintLineNum 87
call :PrintLineNum 88
@echo.
call :PrintLineNum 89
call :PrintLineNum 90
call :PrintLineNum 91
@echo.
@echo.
if [%1]==[] pause >nul
cls
@echo.
call :PrintLineNum 86
@echo.
call :PrintLineNum 87
call :PrintLineNum 88
@echo.
@echo.
if [%1]==[] pause 

REM ; Remove Copilot from taskbar
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d "0" /f >nul 2>&1

rem remove Search bar from Taskbar
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1

rem remove Chat from Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f >nul 2>&1

rem remove Task View button from Taskbar 
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f >nul 2>&1

cls
@echo.
call :PrintLineNum 6
@echo.
@echo.
call :PrintLineNum 89
call :PrintLineNum 90
call :PrintLineNum 91
@echo.
@echo.
if [%1]==[] pause >nul
if [%1]==[] pause

@echo.
@echo.
call :PrintLineNum 11

rem creating date-time auto-named folder for backup
set datetime=(%DATE%)-(%TIME%)
set datetime=%datetime:/=0%
set datetime=%datetime::=0%
md "%~dp0_user-files\_tweaks\_start-menu-layouts\start-menu-layout_%datetime%"
rem creating backup of Start menu pinned icons layout
"%~dp0_tools\_apps\Backup-Start-Menu-Layout\BackupSML.exe" /C "%~dp0_tools\_apps\Backup-Start-Menu-Layout\MenuLayouts\start-menu-layout_%datetime%"

rem adding shortcut for Local Group Policy Editor in Start Menu (to pin it in Start Menu)
if not exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows System\" (
	md "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\" >nul 2>&1
)
powershell.exe "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Local Group Policy Editor.lnk');$s.TargetPath='c:\windows\system32\mmc.exe';$s.Arguments='c:\windows\system32\gpedit.msc';$s.IconLocation='C:\Windows\System32\gpedit.dll';$s.WorkingDirectory='%~dp0';$s.WindowStyle=7;$s.Save()"

rem removing all pinned apps from taskbar
del /f /s /q /a "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" >nul 2>&1
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "Favorites" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "FavoritesResolve" /f >nul 2>&1
"%~dp0_tools\_apps\pttb_pin-to-taskbar\pttb.exe" -r
rem pinning standard daily apps to taskbar
"%~dp0_tools\_apps\pttb_pin-to-taskbar\pttb.exe" c:\windows\explorer.exe
"%~dp0_tools\_apps\pttb_pin-to-taskbar\pttb.exe" -r
"%~dp0_tools\_apps\pttb_pin-to-taskbar\pttb.exe" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
"%~dp0_tools\_apps\pttb_pin-to-taskbar\pttb.exe" -r

rem applying Start menu pinned icons layout
if UILanguage==0419 (
	"%~dp0_tools\_apps\Backup-Start-Menu-Layout\BackupSML.exe" /R "%~dp0_tools\_apps\Backup-Start-Menu-Layout\MenuLayouts\TweakTimeSaver_StartMenu_Ru\"
) else (
	"%~dp0_tools\_apps\Backup-Start-Menu-Layout\BackupSML.exe" /R "%~dp0_tools\_apps\Backup-Start-Menu-Layout\MenuLayouts\TweakTimeSaver_StartMenu_En\"
)

@echo.
@echo.
call :PrintLineNum 6
@echo.
if [%1]==[] pause
exit /b




:PrintLineNum
set LineNum=%1
set /a LineNum-=1
for /f "usebackq delims=" %%a in (`more +%LineNum% "%~dp0_translations\messages_%UILanguage%.txt"`) do (
	echo %%a
	exit /b
)

:SetWindowTitle
set LineNum=%1
set /a LineNum-=1
for /f "usebackq delims=" %%a in (`more +%LineNum% "%~dp0_translations\messages_%UILanguage%.txt"`) do (
	title %%a
	exit /b
)


:CheckTranslastionFileAvailable
rem set English language if language file was not found
if not exist "%~dp0_translations\messages_%UILanguage%.txt" (
	set UILanguage=0409
)
:eof
exit /b