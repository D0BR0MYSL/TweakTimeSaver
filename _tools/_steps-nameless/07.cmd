@echo off

rem silently closing GeekDropProps.exe background process after previous step
taskkill /F /IM GeekDropProps.exe >nul 2>&1

setlocal enableextensions

set ReadRegistryValueResult=


set RegKeyArg=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders

set RegParamArg=My Music
call :ReadRegistryValue
set ShellFolderMusic=%ReadRegistryValueResult%

set RegParamArg=My Pictures
call :ReadRegistryValue
set ShellFolderPictures=%ReadRegistryValueResult%

set RegParamArg=My Video
call :ReadRegistryValue
set ShellFolderVideos=%ReadRegistryValueResult%

set RegParamArg={4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}
call :ReadRegistryValue
set ShellFolderMyGames=%ReadRegistryValueResult%

for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /V "Personal" ^|findstr /ri "REG_SZ"') do set ShellFolderDocuments=%%a

for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /V "{374DE290-123F-4565-9164-39C4925E467B}" ^|findstr /ri "REG_SZ"') do set ShellFolderDownloads=%%a


if exist "%~dp0_tools\_apps\GeekDropProps\GeekDropProps.exe" (
	start /d "%~dp0_tools\_apps\GeekDropProps" GeekDropProps.exe %ShellFolderVideos%
	start /d "%~dp0_tools\_apps\GeekDropProps" GeekDropProps.exe %ShellFolderMusic%
	start /d "%~dp0_tools\_apps\GeekDropProps" GeekDropProps.exe %ShellFolderMyGames%
	start /d "%~dp0_tools\_apps\GeekDropProps" GeekDropProps.exe %ShellFolderPictures%
	start /d "%~dp0_tools\_apps\GeekDropProps" GeekDropProps.exe %ShellFolderDocuments%
	start /d "%~dp0_tools\_apps\GeekDropProps" GeekDropProps.exe %ShellFolderDownloads%
) else (
	start explorer file:"%UserProfile%\Documents\"
	start explorer file:"%UserProfile%\Downloads\"
	start explorer file:"%UserProfile%\Pictures\"
	start explorer file:"%UserProfile%\Videos\"
	start explorer file:"%UserProfile%\Downloads\"
	start explorer file:"%UserProfile%\My Games\"
)

exit /b



:ReadRegistryValue
for /f "tokens=1,2* skip=2 delims=:" %%a in ('REG QUERY "%RegKeyArg%" /v "%RegParamArg%" 2^>nul') do (set "regA=%%a" & set "regB=%%b")
set ReadRegistryValueResult=%regA:~-1%:%regB%
exit /b