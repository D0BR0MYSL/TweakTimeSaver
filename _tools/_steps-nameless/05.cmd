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

>NUL 2>&1 REG QUERY "HKU\S-1-5-19" ||(
	echo.
	call :PrintLineNum 5
 	echo.
	pause >nul
	pause
	goto :eof
)

rem getting User SID
for /F "tokens=2" %%i in ('whoami /user /fo table /nh') do set usersid=%%i

@echo.
call :PrintLineNum 77
call :PrintLineNum 78
call :PrintLineNum 79
call :PrintLineNum 80
call :PrintLineNum 81
call :PrintLineNum 82
@echo.
@echo.
if [%1]==[] pause >nul
if [%1]==[] pause


cls
@echo.
call :PrintLineNum 11

rem Disconnect Hibernation, but leave the Quick Reboot functionality
powercfg.exe /h /type reduced
rem Never sleep automatically
Powercfg /SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0x00000000
rem Turn the screen off when user was inactive - after 2 hours
Powercfg /SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0x00001c20
rem Disable wake timers during Sleep
Powercfg /SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 0x00000000

@echo.
@echo.
@echo.
@echo.
@echo Done,
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