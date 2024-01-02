@echo off

rem silently closing GeekDropProps.exe background process after previous steps
taskkill /F /IM GeekDropProps.exe >nul 2>&1

for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CONTROLSET001\CONTROL\NLS\Language" /v Installlanguage') do set UILanguage=%%a
call :CheckTranslastionFileAvailable

if %UILanguage%==0419 (
	chcp 1251 >nul 2>&1
) else (
	chcp 65001 >nul 2>&1
)

rem program version in cmd window title
call :SetWindowTitle 2

start %SystemRoot%\System32\devmgmt.msc
start explorer.exe "%~dp0_user-files\_drivers\"

if not exist "%~dp0_user-files\_drivers\*.lnk" goto :NoLnkFound

rem Taking full path to the shortcut file for processing
for %%f in ("%~dp0_user-files\_drivers\*.lnk") do set shortcut_path=%%f

rem non-English language specific operation:
rem temporarily changing codepage that matches the system command console's codepage
rem to set "extracted_path" variable value in system console codepage, so that it will
rem be converted corretly when @echoed and used
if %UILanguage%==0419 chcp 866 >nul 2>&1

rem Extract target from shortcut
if not "%shortcut_path%"=="" (
	for /f "delims=" %%a in ('wmic path win32_shortcutfile where "name='%shortcut_path:\=\\%'" get target /value') do for /f "tokens=2 delims==" %%b in ("%%~a") do set extracted_path=%%~b
)

rem Non-English language specific operation:
rem returning codepage to initial value
if %UILanguage%==0419 chcp 1251 >nul 2>&1


if exist "%extracted_path%\" (
	start explorer.exe "%extracted_path%"
)

:NoLnkFound
rem generate .txt "readme" files with language specific names
call :SetFileNameFromLineNum 128
call :SetFileNameFromLineNum 129
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


:SetFileNameFromLineNum
set LineNum=%1
set /a LineNum-=1
for /f "usebackq delims=" %%a in (`more +%LineNum% "%~dp0_translations\messages_%UILanguage%.txt"`) do (
	@echo %%a >"%~dp0_user-files\_drivers\%%a.txt"
	exit /b
)


:PrintDoneMsg
@echo.
@echo.
call :PrintLineNum 6
@echo.
if [%1]==[] pause
exit /b



:CheckTranslastionFileAvailable
rem set English language if language file was not found
if not exist "%~dp0_translations\messages_%UILanguage%.txt" (
	set UILanguage=0409
)
exit /b