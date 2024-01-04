@echo off

rem silently closing GeekDropProps.exe background process after previous step
taskkill /F /IM GeekDropProps.exe >nul 2>&1

cls

for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CONTROLSET001\CONTROL\NLS\Language" /v Installlanguage') do set UILanguage=%%a
call :CheckTranslastionFileAvailable

if %UILanguage%==0419 (
	chcp 1251 >nul 2>&1
) else (
	chcp 65001 >nul 2>&1
)

rem program version in cmd window title
call :SetWindowTitle 2

rem removing temporary file served for uploading an empty directory on Github
if exist "%~dp0_user-files\_files-c\dummy.txt" (
	del /f /q "%~dp0_user-files\_files-c\dummy.txt" >nul 2>&1
)

rem checking if any subfolders exist inside user folder for drive C content
for /d %%g in ("%~dp0_user-files\_files-c\*") do (
	set UserFolderProcessing=True
)

if not exist "%~dp0_user-files\_files-c\*.lnk" goto :SkipShortcutProcessing

rem Taking full path to the shortcut file for processing
for %%f in ("%~dp0_user-files\_files-c\*.lnk") do set shortcut_path=%%f

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
	set ShortcutProcessing=true

	@echo.
	call :PrintLineNum 132
	@echo %shortcut_path%
	@echo.
	@echo.
	call :PrintLineNum 133
	call :PrintLineNum 137
	@echo %extracted_path%\

	if defined UserFolderProcessing (
		@echo.
		@echo.
		call :PrintLineNum 134
		@echo %~dp0_user-files\_files-c\
	)

	@echo.
	@echo.
	call :PrintLineNum 138
	@echo.
	@echo.
	if [%1]==[] pause >nul
	if [%1]==[] pause

	xcopy "%extracted_path%\" "%SystemDrive%\" /S/E/F/Y

	@echo.
	@echo.
	call :PrintLineNum 6
	@echo.
	@echo.
)

:SkipShortcutProcessing

if defined UserFolderProcessing (

	if not defined ShortcutProcessing (
		@echo.
		call :PrintLineNum 133
		call :PrintLineNum 137
		@echo %~dp0_user-files\_files-c\
		@echo.
		call :PrintLineNum 138
		@echo.
		@echo.
		if [%1]==[] pause >nul
		if [%1]==[] pause
		rem removing generated "readme" files before start
		rem (warning: it's kind of a dirty way, so better not put any txt-files for C-drive root)
		del /f /q "%~dp0_user-files\_files-c\*.txt" >nul 2>&1

		rem temprorarily moving shortcuts from the root of user's "files-c" backup content
		rem (warning: it's kind of a dirty way, so just know this before putting any lnk-files for C-drive root)
		move "%~dp0_user-files\_files-c\*.lnk" "%temp%\" >nul 2>&1

		xcopy "%~dp0_user-files\_files-c\" "%SystemDrive%\" /S/E/F/Y
	)

	if defined ShortcutProcessing (
		rem removing generated "readme" files before start
		rem (warning: it's kind of a dirty way, so better not put any txt-files for C-drive root)
		del /f /q "%~dp0_user-files\_files-c\*.txt" >nul 2>&1

		rem temprorarily moving shortcuts from the root of user's "files-c" backup content
		rem (warning: it's kind of a dirty way, so just know this before putting any lnk-files for C-drive root)
		md "%temp%\bj43a-tp4f9-n5uj2\" >nul 2>&1
		move "%~dp0_user-files\_files-c\*.lnk" "%temp%\bj43a-tp4f9-n5uj2\" >nul 2>&1

		xcopy "%~dp0_user-files\_files-c\" "%SystemDrive%\" /S/E/F/Y

		move "%temp%\bj43a-tp4f9-n5uj2\*.lnk" "%~dp0_user-files\_files-c\" >nul 2>&1
		rd /s /q "%temp%\bj43a-tp4f9-n5uj2" >nul 2>&1

		@echo.
		@echo.
		@echo.
		@echo.
		call :PrintLineNum 6
		@echo.
		@echo.
		if [%1]==[] pause
	)
	exit /b
)

if not defined UserFolderProcessing (
	if not defined ShortcutProcessing (
		rem generate .txt "readme" files with language specific names
		call :SetFileNameFromLineNum 135
		call :SetFileNameFromLineNum 136

		rem show "readme" files in user fonts folder
		explorer.exe "%~dp0_user-files\_files-c\"
		goto :eof
	)
)

@echo.
@echo.
@echo.
@echo.
call :PrintLineNum 6
@echo.
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


:SetFileNameFromLineNum
set LineNum=%1
set /a LineNum-=1
for /f "usebackq delims=" %%a in (`more +%LineNum% "%~dp0_translations\messages_%UILanguage%.txt"`) do (
	@echo %%a >"%~dp0_user-files\_files-c\%%a.txt"
	exit /b
)


:CheckTranslastionFileAvailable
rem set English language if language file was not found
if not exist "%~dp0_translations\messages_%UILanguage%.txt" (
	set UILanguage=0409
)
exit /b

:eof
exit /b