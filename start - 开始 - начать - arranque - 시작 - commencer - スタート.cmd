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







if not exist 00*.cmd (
	xcopy "%~dp0_tools\_steps-nameless\*.cmd" "%~dp0" /S/E/F/Y >nul 2>&1
) else (
	del /f /q 0*.cmd >nul 2>&1
	del /f /q 1*.cmd >nul 2>&1
	del /f /q 66*.cmd >nul 2>&1
	del /f /q 99*.cmd >nul 2>&1
	xcopy "%~dp0_tools\_steps-nameless\*.cmd" "%~dp0" /S/E/F/Y >nul 2>&1
)

call :RenameStepFile 00-1 210
call :RenameStepFile 00-2 211
call :RenameStepFile 01 212
call :RenameStepFile 02 213
call :RenameStepFile 03 214
call :RenameStepFile 04 215
call :RenameStepFile 05 216
call :RenameStepFile 06 217
call :RenameStepFile 07 218
call :RenameStepFile 08 219
call :RenameStepFile 09 220
call :RenameStepFile 10 221
call :RenameStepFile 11 222
call :RenameStepFile 66 223
call :RenameStepFile 99 224

exit /b




:RenameStepFile
set StepNum=%1
set LineNum=%2
set /a LineNum-=1

setlocal enabledelayedexpansion
set count=1
for /f "tokens=* usebackq" %%f in (`more +%LineNum% "%~dp0_translations\messages_%UILanguage%.txt"`) do (
  set var!count!=%%f
  set /a count=!count!+1
)
ren %StepNum%.cmd "%var1%"
exit /b
	

:SetWindowTitle
set LineNum=%1
set /a LineNum-=1
for /f "usebackq delims=" %%a in (`more +%LineNum% "%~dp0_translations\messages_%UILanguage%.txt"`) do (
	title %%a
	exit /b
)
exit /b

:CheckTranslastionFileAvailable
rem set English language if language file was not found
if not exist "%~dp0_translations\messages_%UILanguage%.txt" (
	set UILanguage=0409
)
:eof
exit /b