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

if not exist "%~dp0_user-files\_fonts\*.lnk" goto :NoLnkFound

rem Taking full path to the shortcut file for processing
for %%f in ("%~dp0_user-files\_fonts\*.lnk") do set shortcut_path=%%f

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

if exist "%extracted_path%\*.?tf" (
	rem Installing fonts taken through the .lnk-file
	@echo.
	call :PrintLineNum 144
	@echo %shortcut_path%
	@echo.
	call :PrintLineNum 145
	call :PrintLineNum 146
	@echo %extracted_path%\
	if exist "%~dp0_user-files\_fonts\*.?tf" (
		@echo.
		call :PrintLineNum 148
		@echo %~dp0_user-files\_fonts\
	)

	@echo.
	if [%1]==[] pause >nul
	if [%1]==[] pause

	@echo.
	call :PrintLineNum 147

	call :InstallFontsFromLnkPath

	rem Installing fonts from ".\_user-files\_fonts\" directory if there any
	if exist "%~dp0_user-files\_fonts\*.?tf" (
		call :InstallFontsFromUserFiles
	)

	@echo.
	@echo.
	call :PrintLineNum 6
	@echo.
	@echo.
	if [%1]==[] pause

	exit /b

)

:NoLnkFound

rem if there was no .lnk-file then try installing from ".\_user-files\_fonts\" directory
if exist "%~dp0_user-files\_fonts\*.?tf" (
	@echo.
	call :PrintLineNum 145
	call :PrintLineNum 146
	@echo %~dp0_user-files\_fonts\
	@echo.
	if [%1]==[] pause >nul
	if [%1]==[] pause
	@echo.
	call :PrintLineNum 147

	call :InstallFontsFromUserFiles

	@echo.
	@echo.
	call :PrintLineNum 6
	@echo.
	if [%1]==[] pause

	exit /b

) else (
	rem generate .txt "readme" files with language specific names
	call :SetFileNameFromLineNum 149
	call :SetFileNameFromLineNum 150

	rem show "readme" files in user fonts folder
	start explorer "%~dp0_user-files\_fonts\"
)

exit /b


:InstallFontsFromUserFiles
	rem Installing fonts from ".\_user-files\_fonts\" directory if there any
	copy /Y "%~dp0_tools\_apps\fontreg\fontreg.exe" "%~dp0_user-files\_fonts\" >nul

	rem set working directory for fontreg.exe
	set fullpath=%~dp0
	set driveletter=%fullpath:~0,1%
	%driveletter%:
	cd "%~dp0_user-files\_fonts\"
	
	FontReg.exe /copy

	del /f/q FontReg.exe >nul

	exit /b


:InstallFontsFromLnkPath
	rem Installing fonts from user's external directory if there any
	copy /Y "%~dp0_tools\_apps\fontreg\fontreg.exe" "%extracted_path%\" >nul

	rem set working directory for fontreg.exe
	set driveletter1=%extracted_path:~0,1%
	%driveletter1%:
	cd %extracted_path%

	FontReg.exe /copy

	del /f/q FontReg.exe >nul
	
	exit /b


:SetFileNameFromLineNum
set LineNum=%1
set /a LineNum-=1
for /f "usebackq delims=" %%a in (`more +%LineNum% "%~dp0_translations\messages_%UILanguage%.txt"`) do (
	@echo %%a >"%~dp0_user-files\_fonts\%%a.txt"
	exit /b
)


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