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

@echo.
call :PrintLineNum 4
@echo.
systeminfo | findstr /i /c:"windows 11" > nul && set Windows=11 || set Windows=10

cls
@echo.
call :PrintLineNum 14
call :PrintLineNum 15
call :PrintLineNum 17
call :PrintLineNum 18
@echo.
@echo.
if [%1]==[] pause

rem getting User SID
for /F "tokens=2" %%i in ('whoami /user /fo table /nh') do set usersid=%%i

if exist %systemroot%\Fonts\JetBrainsMonoNL-Regular.ttf goto :start

rem optional font for the console: "Jetbrains Mono NL"
if not exist "%~dp0_tools\_apps\fontreg\JetBrainsMonoNL*.ttf" goto :start
pushd "%~dp0_tools\_apps\fontreg"
FontReg.exe /copy
popd

:start

if exist "%userprofile%\AppData\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\wt.exe" (
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DelegationConsole" /t REG_SZ /d "{06EC847C-C0A5-46B8-92CB-7C92F6E35CD5}" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DelegationTerminal" /t REG_SZ /d "{86633F1F-6454-40EC-89CE-DA4EBA977EE2}" /f >nul 2>&1
	Reg.exe add "HKU\%usersid%\Console\%%%%Startup" /v "DelegationConsole" /t REG_SZ /d "{06EC847C-C0A5-46B8-92CB-7C92F6E35CD5}" /f >nul 2>&1
	Reg.exe add "HKU\%usersid%\Console\%%%%Startup" /v "DelegationTerminal" /t REG_SZ /d "{86633F1F-6454-40EC-89CE-DA4EBA977EE2}" /f >nul 2>&1
)

copy /Y "%~dp0_tools\_tweaks\template-console-darktheme.reg" "%~dp0_tools\_tweaks\console-darktheme-%usersid%.reg" >nul 2>&1

"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%~dp0_tools\_tweaks" --fileMask "console-darktheme-%usersid%.reg" --find "usersid" --replace "%usersid%" >nul 2>&1

if exist %systemroot%\Fonts\JetBrainsMonoNL-Regular.ttf (
	"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%~dp0_tools\_tweaks" --fileMask "console-darktheme-%usersid%.reg" --find "Consolas" --replace "JetBrains Mono NL" >nul 2>&1
)

cls
Regedit.exe /S "%~dp0_tools\_tweaks\console-darktheme-%usersid%.reg"

copy /Y "%~dp0_tools\_tweaks\wt-theme-dark\*.json" "%userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\" >nul 2>&1
copy /Y "%~dp0_tools\_tweaks\wt-theme-dark\*.json" "%userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\" >nul 2>&1

if exist %systemroot%\Fonts\JetBrainsMonoNL-Regular.ttf (
	"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState" --fileMask "settings.json" --find "Consolas" --replace "JetBrains Mono NL" >nul 2>&1
	cls
	"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" --fileMask "settings.json" --find "Consolas" --replace "JetBrains Mono NL" >nul 2>&1
	cls
)

if exist "%~dp0_tools\_tweaks\console-darktheme-%usersid%.reg" (
	del /f /q "%~dp0_tools\_tweaks\console-darktheme-%usersid%.reg" >nul 2>&1
)

rem dark theme for apps and windows
Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\DWM" /v "ColorPrevalence" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v "ColorPrevalence" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "0" /f >nul 2>&1

rem dark theme for onscreen keyboard
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7" /v "SelectedThemeIndex" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7" /v "SelectedThemeName" /t REG_SZ /d "DarkTheme" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeDark" /v "KeyboardBackgroundSolidColor" /t REG_SZ /d "28,28,28" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeDark" /v "KeyLabelColor" /t REG_SZ /d "255,255,255" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeDark" /v "KeyTransparency" /t REG_DWORD /d "87" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeDark" /v "SuggestionTextColor" /t REG_SZ /d "255,255,255" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeDark" /v "ThemeOverride" /t REG_SZ /d "Dark" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeLight" /v "KeyboardBackgroundSolidColor" /t REG_SZ /d "28,28,28" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeLight" /v "KeyLabelColor" /t REG_SZ /d "255,255,255" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeLight" /v "KeyTransparency" /t REG_DWORD /d "87" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeLight" /v "SuggestionTextColor" /t REG_SZ /d "255,255,255" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Microsoft\TabletTip\1.7\SelectedThemeLight" /v "ThemeOverride" /t REG_SZ /d "Dark" /f >nul 2>&1

rem we want to change these settings only on Windows 11
if %Windows%==11 (
	Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\DWM" /v "ColorizationAfterglow" /t REG_DWORD /d "3303543075" /f >nul 2>&1
	Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\DWM" /v "ColorizationColor" /t REG_DWORD /d "3303543075" /f >nul 2>&1
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemProtectedUserData\%usersid%\AnyoneRead\Colors" /v "StartColor" /t REG_DWORD /d "4280159954" /f >nul 2>&1
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemProtectedUserData\%usersid%\AnyoneRead\Colors" /v "AccentColor" /t REG_DWORD /d "4280488424" /f >nul 2>&1
	Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "AccentColorMenu" /t REG_DWORD /d "4280488424" /f >nul 2>&1
	Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "AccentPalette" /t REG_BINARY /d "FB9D8B00F4676200EF273300E8112300D20E1E009E0912006F03060069797E00" /f >nul 2>&1
	Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "StartColorMenu" /t REG_DWORD /d "4280159954" /f >nul 2>&1
	Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\DWM" /v "AccentColor" /t REG_DWORD /d "4280488424" /f >nul 2>&1
)

cls
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