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

rem getting User account name 
for /f "delims=" %%i in ('wmic useraccount get name^,sid ^| findstr /vi "SID"') do @for /F %%a in ("%%i") do if exist "C:\users\%%a" set buffer=%%i
set username=%buffer:~0,18%
set username=%username: =%


set /a TweaksAmount=446

set datetime=


@echo.
call :PrintLineNum 71
call :PrintLineNum 72
@echo.
call :PrintLineNum 73
@echo %TweaksAmount%
@echo.
call :PrintLineNum 9
@echo.
if [%1]==[] pause >nul
if [%1]==[] pause


@echo.
@echo.
call :PrintLineNum 8
@echo "%~dp0_user-files\_tweaks\_group-policy-bakups"
rem creating backup in _user-files folder
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /b "%~dp0_user-files\_tweaks\_group-policy-bakups"


cls
@echo.
call :PrintLineNum 10
%SystemRoot%\System32\CScript.exe "%~dp0_tools\_apps\create-restore-point\create-restore-point.vbs"

rem waiting 6 seconds for restore point creation in background
ping localhost -n 6 >nul 2>&1

cls
@echo.
call :PrintLineNum 11

rem take ownership of temporary system folders
takeown /f "%temp%" /A /r /d y >nul 2>&1
takeown /f "%SystemRoot%\Temp\" /A /r /d y >nul 2>&1
icacls "%temp%" /grant:r *S-1-5-32-544:F /T /C >nul 2>&1
icacls "%SystemRoot%\Temp\" /grant:r *S-1-5-32-544:F /T /C >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen

REM ; Feedback frequency never
Reg.exe add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe delete "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /f >nul 2>&1
set /a TweaksCounter+=2
call :updatescreen

rem deploying additional Group Policy applets from Microsoft
if not exist %SystemDrive%\Windows\PolicyDefinitions\msedge.admx (
	xcopy "%~dp0_tools\_apps\lgpo\Microsoft-Edge-additional-Group-Policy-applets\*.*" "%SystemDrive%\Windows\PolicyDefinitions\" /S/E/F/Y >nul 2>&1
)
set /a TweaksCounter+=1
call :updatescreen

if %UILanguage%==0419 (
	rem convenient date format for long date
	Reg.exe add "HKCU\Control Panel\International" /v "sLongDate" /t REG_SZ /d "yyyy.MM.dd" /f >nul 2>&1

	rem remove unused apps from Windows Store
	powershell.exe -file "%~dp0_tools\_tweaks\windows-store-apps--remove-unused-non-English.ps1"

	rem keyboard Preload usersid - for Russian UI only
	reg add "HKEY_USERS\%usersid%\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Keyboard Layout\Preload" /v "2" /t REG_SZ /d "00000419" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Keyboard Layout\Preload" /v "2" /t REG_SZ /d "00000419" /f >nul 2>&1
	reg add "HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
	reg add "HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" /v "2" /t REG_SZ /d "00000419" /f >nul 2>&1

	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "reg.exe" add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemProtectedUserData\%usersid%\AnyoneRead\LanguageProfile" /v "Profile" /t REG_SZ /d "User Profile#Languages+Men-US@ru@&ShowAutoCorrection+D1&ShowTextPrediction+D1&ShowCasing+D1&ShowShiftLock+D1&WindowsOverride+Sru%%User Profile/en-US#0409:00000409+D1&CachedLanguageName+S@Winlangdb.dll,-1121%%User Profile/ru#0419:00000419+D1&CachedLanguageName+S@Winlangdb.dll,-1390" /f >nul 2>&1
)

if %UILanguage%==0409 (
	rem remove unused apps from Windows Store
	powershell.exe -file "%~dp0_tools\_tweaks\windows-store-apps--remove-unused-English.ps1"
)

set /a TweaksCounter+=9
call :updatescreen

REM ; Disable narrator
Reg.exe add "HKCU\Software\Microsoft\Narrator\NoRoam" /v "DuckAudio" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Narrator\NoRoam" /v "WinEnterLaunchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Narrator\NoRoam" /v "ScriptingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Narrator\NoRoam" /v "OnlineServicesEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Narrator" /v "NarratorCursorHighlight" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Narrator" /v "CoupleNarratorCursorKeyboard" /t REG_DWORD /d "0" /f >nul 2>&1
REM ; Disable ease of access settings
Reg.exe add "HKCU\Software\Microsoft\Ease of Access" /v "selfvoice" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Ease of Access" /v "selfscan" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility" /v "Sound on Activation" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility" /v "Warning Sounds" /t REG_DWORD /d "0" /f >nul 2>&1
rem disable sticky keys and accessebility helpers
Reg.exe add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "2" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "34" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\SoundSentry" /v "Flags" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\SoundSentry" /v "FSTextEffect" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\SoundSentry" /v "TextEffect" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\SoundSentry" /v "WindowsEffect" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\SlateLaunch" /v "ATapp" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\SlateLaunch" /v "LaunchAT" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=18
call :updatescreen


rem reduce SSD deprecation by increasing RAM caching mechnisms
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f >nul 2>&1
set /a TweaksCounter+=3
call :updatescreen


rem Keyboard NumLock at Logon - Enabled
"%~dp0_tools\_apps\PowerRun\PowerRun.exe" /SW:0 "reg.exe" add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f >nul 2>&1
rem faster keyboard responsiveness
Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "2" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f >nul 2>&1
REM ; Alt tab opened windows only
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "MultiTaskingAltTabFilter" /t REG_DWORD /d "3" /f >nul 2>&1
set /a TweaksCounter+=5
call :updatescreen

REM ; Screenshot borders
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
REM ; Screenshots and apps
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
rem disable sleep for Snipping Tools app - allow in background
Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ScreenSketch_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ScreenSketch_8wekyb3d8bbwe" /v "DisabledBySystem" /t REG_DWORD /d "0" /f
Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ScreenSketch_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d "0" /f
Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ScreenSketch_8wekyb3d8bbwe" /v "IgnoreBatterySaver" /t REG_DWORD /d "1" /f
Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ScreenSketch_8wekyb3d8bbwe" /v "SleepDisabled" /t REG_DWORD /d "0" /f
rem disable PrintScr key for Snipping Tool
Reg.exe add "HKU\%usersid%\Control Panel\Keyboard" /v "PrintScreenKeyForSnippingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=5
call :updatescreen

rem Windows Update and Upgrade enable
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "AllowOSUpgrade" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "IncludeRecommendedUpdates" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ActiveHoursEnd" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ActiveHoursStart" /t REG_DWORD /d "17" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "AllowMUUpdateService" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "RestartNotificationsAllowed2" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "SmartActiveHoursState" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "UserChoiceActiveHoursEnd" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "UserChoiceActiveHoursStart" /t REG_DWORD /d "17" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator" /v "ShutdownFlyoutOptions" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "IsExpedited" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" /v "DownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=13
call :updatescreen

rem MS Edge Browser - disable sticky confirmation about experience personilization
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "PersonalizationReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
rem MS Edge Browser - disable "Follow Creators" feature popups
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "EdgeFollowEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
rem MS Edge Browser - don't re-create shortcut on desktop after each update 
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d "0" /f >nul 2>&1
rem MS Edge Browser - disable user feedback
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "UserFeedback" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=4
call :updatescreen


rem Bigger Mouse Cursors
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "AppStarting" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\wait_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "Arrow" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\arrow_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "ContactVisualization" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "Crosshair" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\cross_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "CursorBaseSize" /t REG_DWORD /d "32" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "GestureVisualization" /t REG_DWORD /d "31" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "Hand" /t REG_EXPAND_SZ /d "" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "Help" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\help_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "IBeam" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\beam_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "No" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\no_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "NWPen" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\pen_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "Person" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\person_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "Pin" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\pin_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "Scheme Source" /t REG_DWORD /d "2" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "SizeAll" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\move_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "SizeNESW" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\size1_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "SizeNS" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\size4_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "SizeNWSE" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\size2_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "SizeWE" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\size3_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "UpArrow" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\up_m.cur" /f >nul 2>&1
Reg add "HKU\%usersid%\Control Panel\Cursors" /v "Wait" /t REG_EXPAND_SZ /d "%SystemRoot%\cursors\busy_m.cur" /f >nul 2>&1
set /a TweaksCounter+=23
call :updatescreen

REM ;Classic view for Control panel
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ForceClassicControlPanel" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "StartupPage" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "AllItemsIconView" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "StartupPage" /t REG_DWORD /d "1" /f >nul 2>&1
set /a TweaksCounter+=4
call :updatescreen

REM ;Do not scan for network printers
Reg.exe delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\RemoteComputer\NameSpace\{863aa9fd-42df-457b-8e4d-0de1b8015c60}" /f >nul 2>&1


rem Visual effects settings
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ComboBoxAnimation" /v "DefaultApplied" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ControlAnimations" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMAeroPeekEnabled" /v "DefaultApplied" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMEnabled" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMSaveThumbnailEnabled" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListBoxSmoothScrolling" /v "DefaultApplied" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade" /v "DefaultApplied" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TaskbarAnimations" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\Themes" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ThumbnailsOrIcon" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation" /v "DefaultApplied" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=21
call :updatescreen

rem context menu while holding Shift button - Take ownership and gain full accsess
if %UILanguage%==0419 (
	copy /Y "%~dp0_tools\_tweaks\template-contextmenu-takeown_ru-RU.reg" "%~dp0_tools\_tweaks\contextmenu-takeown-%usersid%.reg" >nul 2>&1
) else (
	copy /Y "%~dp0_tools\_tweaks\template-contextmenu-takeown_en-US.reg" "%~dp0_tools\_tweaks\contextmenu-takeown-%usersid%.reg" >nul 2>&1
)
"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%~dp0_tools\_tweaks" --fileMask "contextmenu-takeown-%usersid%.reg" --find "usersid" --replace "%usersid%"
"%~dp0_tools\_apps\PowerRun\PowerRun.exe" Regedit.exe /S "%~dp0_tools\_tweaks\contextmenu-takeown-%usersid%.reg"
del /f /q "%~dp0_tools\_tweaks\contextmenu-takeown-%usersid%.reg" >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen


rem context menu while holding Shift button - Allow accsess to the Internet
if %UILanguage%==0419 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" Regedit.exe /S "%~dp0_tools\_tweaks\contextmenu-exe-netaccess_ru-RU.reg"
) else (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" Regedit.exe /S "%~dp0_tools\_tweaks\contextmenu-exe-netaccess_en-US.reg"
)
set /a TweaksCounter+=1
call :updatescreen


rem decluttering classic context menu of Files Explorer
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{55B3A0BD-4D28-42fe-8CFB-FA3EDFF969B8}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{7EFA68C6-086B-43e1-A2D2-55A113531240}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{474C98EE-CF3D-41f5-80E3-4AAB0AB04301}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{888DCA60-FC0A-11CF-8F0F-00C04FD7D062}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{BD472F60-27FA-11cf-B8B4-444553540000}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{ed9d80b9-d157-457b-9192-0e7280313bf0}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{b8cdcb65-b1bf-4b42-9428-1dfdb7ee92af}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{1206F5F1-0569-412C-8FEC-3204630DFB70}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{8FD8B88D-30E1-4F25-AC2B-553D3D65F0EA}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{D555645E-D4F8-4c29-A827-D93C859C4F2A}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{2F6CE85C-F9EE-43CA-90C7-8A9BD53A2467}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{F6B6E965-E9B2-444B-9286-10C9152EDBC5}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{FF393560-C2A7-11CF-BFF4-444553540000}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{21F5E992-636E-48DC-9C47-5B05DEF82372}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{66275315-bfa5-451b-88b6-e56ebc8d9b58}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{14074e0b-7216-4862-96e6-53cada442a56}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{0af96ede-aebf-41ed-a1c8-cf7a685505b6}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{7988B573-EC89-11cf-9C00-00AA00A14F56}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{596AB062-B4D2-4215-9F74-E9109B0A8153}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{035B18F9-A217-44D5-91C9-B682C33C1078}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{40dd6e20-7c17-11ce-a804-00aa003ca9f6}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{fbeb8a05-beee-4442-804e-409d6c4515e9}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{B98A2BEA-7D42-4558-8BD1-832F41BAC6FD}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{9FE63AFD-59CF-4419-9775-ABCC3849F861}" /t REG_SZ /d "" /f >nul 2>&1
REM ;copy as path
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{f3d06e7c-1e45-4a26-847e-f9fcdee59be0}" /t REG_SZ /d "" /f >nul 2>&1
REM ;copy to
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{C2FBB630-2971-11D1-A18C-00C04FD75D13}" /t REG_SZ /d "" /f >nul 2>&1
REM ;move to
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{C2FBB631-2971-11D1-A18C-00C04FD75D13}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe delete "HKCR\Allfilesystemobjects\shell\CopyPath" /f >nul 2>&1
Reg.exe delete "HKLM\SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To" /f >nul 2>&1
Reg.exe delete "HKLM\SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To" /f >nul 2>&1
Reg.exe delete "HKLM\SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyAsPathMenu" /f >nul 2>&1



if not exist "%APPDATA%\TweakTimeSaver\" (
	mkdir "%APPDATA%\TweakTimeSaver" >nul 2>&1
)
copy "%~dp0_tools\_tweaks\TweakTimeSaver-Schedule-Task.cmd" "%APPDATA%\TweakTimeSaver\" /Y >nul 2>&1
call "%APPDATA%\TweakTimeSaver\TweakTimeSaver-Schedule-Task.cmd"
set /a TweaksCounter+=56
call :updatescreen


rem Disable fax service
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Fax" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe config Fax start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe stop Fax >nul 2>&1
)
set /a TweaksCounter+=1
call :updatescreen


rem Accessibility settings
reg add "HKEY_USERS\.DEFAULT\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
reg add "HKEY_USERS\.DEFAULT\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
reg add "HKEY_USERS\.DEFAULT\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Narrator\NoRoam" /v "OnlineServicesEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Narrator\NoRoam" /v "RunningState" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Narrator\NoRoam" /v "WinEnterLaunchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=6
call :updatescreen


rem developer mode settings
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v "AllowDevelopmentWithoutDevLicense" /t REG_DWORD /d "1" /f >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen


rem disabling nvidia telemetry, if nvdidia service exists
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer >nul 2>&1
if %errorlevel%==1 reg add "HKLM\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" /v "start" /t REG_DWORD /d 4 /f >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen


REM ; Battery options optimize for video quality
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\VideoSettings" /v "VideoQualityOnBattery" /t REG_DWORD /d "1" /f >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen


REM ; Turn on hardware accelerated gpu scheduling
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen

rem optimize overall system responsiveness
reg add "HKEY_USERS\%usersid%\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Control Panel\Deskqktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "Append Completion" /t REG_SZ /d "yes" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "AutoSuggest" /t REG_SZ /d "yes" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "LinkResolveIgnoreLinkInfo" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d 00000000 /f >nul 2>&1
set /a TweaksCounter+=15
call :updatescreen


REM ;add "control userpasswords2" applet to Classic Control panel
Reg.exe add "HKLM\Software\Classes\CLSID\{98641F47-8C25-4936-BEE4-C2CE1298969D}" /ve /t REG_SZ /d "@netplwiz,-12182" /f >nul 2>&1
Reg.exe add "HKLM\Software\Classes\CLSID\{98641F47-8C25-4936-BEE4-C2CE1298969D}\DefaultIcon" /ve /t REG_EXPAND_SZ /d "%%systemroot%%\system32\netplwiz.dll,-112" /f >nul 2>&1
Reg.exe add "HKLM\Software\Classes\CLSID\{98641F47-8C25-4936-BEE4-C2CE1298969D}\Shell\Open\command" /ve /t REG_SZ /d "rundll32.exe netplwiz.dll,UsersRunDll" /f >nul 2>&1
Reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{98641F47-8C25-4936-BEE4-C2CE1298969D}" /ve /t REG_SZ /d "control userpasswords2 to Control Panel" /f >nul 2>&1


rem Disable diagnosticshub.standardcollector.service
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe config diagnosticshub.standardcollector.service start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe stop diagnosticshub.standardcollector.service >nul 2>&1
)

rem Disable diagnostic service
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\diagsvc" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe config diagsvc start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe stop diagsvc >nul 2>&1
)

rem Disable giagnosting tracking service
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DiagTrack" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe config DiagTrack start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe stop DiagTrack >nul 2>&1
)

rem restoring local group policy predefined profile
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /m "%~dp0_tools\_apps\lgpo\tweaks_apply.pol"
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /ua "%~dp0_tools\_apps\lgpo\tweaks_apply.pol"
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /u:%username% "%~dp0_tools\_apps\lgpo\tweaks_apply.pol"
set /a TweaksCounter+=74
call :updatescreen

rem Open With Dialog - Disable Store Apps Search
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /t REG_DWORD /d 00000001 /f >nul 2>&1
rem disable Windows Store notifications
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App" /v "Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
set /a TweaksCounter+=2
call :updatescreen

rem disable google chrome telemetry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupReportingEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v "UserFeedbackAllowed" /t REG_DWORD /d 00000000 /f >nul 2>&1
set /a TweaksCounter+=5
call :updatescreen

rem disabe firefox telemetry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableDefaultBrowserAgent" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableTelemetry" /t REG_DWORD /d 00000001 /f >nul 2>&1
set /a TweaksCounter+=2
call :updatescreen


rem disabe office telemetry
reg query "HKEY_USERS\%usersid%\Software\Microsoft\Office\15.0" >nul 2>&1 (
if %errorlevel%==0 (
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\15.0\Common" /v "QMEnable" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\15.0\Common\Feedback" /v "Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\15.0\Outlook\Options\Calendar" /v "EnableCalendarLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\15.0\Outlook\Options\Mail" /v "EnableLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\15.0\Word\Options" /v "EnableLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\15.0\OSM" /v "EnableLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\15.0\OSM" /v "EnableUpload" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\15.0\OSM" /v "EnableLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\15.0\OSM" /v "EnableUpload" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\Common\ClientTelemetry" /v "DisableTelemetry" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\Common\ClientTelemetry" /v "VerboseLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
)
reg query "HKEY_USERS\%usersid%\Software\Microsoft\Office\16.0" >nul 2>&1 (
if %errorlevel%==0 (
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\16.0\Common" /v "QMEnable" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\16.0\Common\ClientTelemetry" /v "DisableTelemetry" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\16.0\Common\ClientTelemetry" /v "VerboseLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\16.0\Common\Feedback" /v "Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\16.0\Outlook\Options\Calendar" /v "EnableCalendarLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\16.0\Outlook\Options\Mail" /v "EnableLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\16.0\Word\Options" /v "EnableLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\Common\ClientTelemetry" /v "DisableTelemetry" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Microsoft\Office\Common\ClientTelemetry" /v "VerboseLogging" /t REG_DWORD /d 00000000 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "accesssolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "olksolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "onenotesolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "pptsolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "projectsolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "publishersolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "visiosolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "wdsolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "xlsolution" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "agave" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "appaddins" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "comaddins" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "documentfiles" /t REG_DWORD /d 00000001 /f >nul 2>&1
	reg add "HKEY_USERS\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "templatefiles" /t REG_DWORD /d 00000001 /f >nul 2>&1
)

rem enable game mode
reg add "HKU\%usersid%\Software\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "SwapEffectUpgradeEnable=1;" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\DirectX\UserGpuPreferences" /v "SwapEffectUpgradeCache" /t REG_DWORD /d "1;" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=4
call :updatescreen

rem enable long paths
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 00000001 /f >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen

rem keyboard and hotkeys settings
"%~dp0_tools\_apps\PowerRun\PowerRun.exe" /SW:0 "reg.exe" add "HKEY_USERS\.DEFAULT\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
"%~dp0_tools\_apps\PowerRun\PowerRun.exe" /SW:0 "reg.exe" add "HKEY_USERS\.DEFAULT\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
"%~dp0_tools\_apps\PowerRun\PowerRun.exe" /SW:0 "reg.exe" add "HKEY_USERS\.DEFAULT\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
set /a TweaksCounter+=3
call :updatescreen

rem Disable fax service
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Fax" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe config Fax start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" sc.exe stop Fax >nul 2>&1
)

rem network throttling optimization
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d ffffffff /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 00000000 /f >nul 2>&1
set /a TweaksCounter+=2
call :updatescreen

rem Enabling periodic Registry backups
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager" /v "EnablePeriodicBackup" /t REG_DWORD /d "1" /f >nul 2>&1

rem don't add "shortcut to"
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link"=hex:00,00,00,00 /f >nul 2>&1

rem Control Panel - show all icons and small icons
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "AllItemsIconView" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "StartupPage" /t REG_DWORD /d 00000001 /f >nul 2>&1
rem Do not automatically reboot at system crash
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v "AutoReboot" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v "CrashDumpEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1

rem Prohibit remote control of this computer
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d 00000000 /f >nul 2>&1

rem Disable defragmentastion service
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\defragsvc" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "sc.exe" config defragsvc start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "sc.exe" stop defragsvc >nul 2>&1
)

rem Disable defragmentastion service
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\defragsvc" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "sc.exe" config defragsvc start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "sc.exe" stop defragsvc >nul 2>&1
)

rem Disable autonomous files driver
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSC" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "sc.exe" config CSC start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "sc.exe" stop CSC >nul 2>&1
)
rem Disable autonomous files service
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CscService" >nul 2>&1
if %errorlevel%==0 (
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "sc.exe" config CscService start= disabled >nul 2>&1
	"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "sc.exe" stop CscService >nul 2>&1
)
set /a TweaksCounter+=9
call :updatescreen

rem regedit font
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RegEdit" /v "FontFace" /t REG_SZ /d "Segoe UI" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RegEdit" /v "FontItalic" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RegEdit" /v "FontWeight" /t REG_DWORD /d 00000190 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RegEdit" /v "FontSize" /t REG_DWORD /d 0000006e /f >nul 2>&1

rem Scrollbars - Wider and Always visible
reg add "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" /v "ScrollHeight" /t REG_SZ /d "-360" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" /v "ScrollWidth" /t REG_SZ /d "-360" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Control Panel\Accessibility" /v "DynamicScrollbars" /t REG_DWORD /d "0" /f >nul 2>&1

rem Store Apps - Disable Install at Login
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.GetHelp_8wekyb3d8bbwe" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Getstarted_8wekyb3d8bbwe" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe" /f >nul 2>&1

set /a TweaksCounter+=11
call :updatescreen

rem disable voice recognition
reg add "HKU\%usersid%\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v "HasAccepted" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen

REM ; Disable startup sound
Reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" /v "DisableStartupSound" /t REG_DWORD /d "1" /f >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen

rem install much conveniently readable fonts and set them for system interface: Open Sans, Jetbrains Mono NL
if exist "%~dp0_tools\_apps\fontreg\OpenSans-*.ttf" (

	pushd "%~dp0_tools\_apps\fontreg"
	FontReg.exe /copy
	popd

	rem reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Segoe UI (TrueType)" /t REG_SZ /d "" /f >nul 2>&1
	rem reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Segoe UI Bold (TrueType)" /t REG_SZ /d "" /f >nul 2>&1
	rem reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Segoe UI Bold Italic (TrueType)" /t REG_SZ /d "" /f >nul 2>&1
	rem reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Segoe UI Italic (TrueType)" /t REG_SZ /d "" /f >nul 2>&1
	rem reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Segoe UI Light (TrueType)" /t REG_SZ /d "" /f >nul 2>&1
	rem reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Segoe UI Semibold (TrueType)" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /v "Segoe UI" /t REG_SZ /d "Open Sans" /f >nul 2>&1

	reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "CaptionFont" /t REG_BINARY /d "f1ffffff00000000000000000000000090010000000000cc000000004f00700065006e002000530061006e00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "IconFont" /t REG_BINARY /d "f3ffffff00000000000000000000000090010000000000cc000000004f00700065006e002000530061006e00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MenuFont" /t REG_BINARY /d "f3ffffff00000000000000000000000090010000000000cc000000004f00700065006e002000530061006e00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MessageFont" /t REG_BINARY /d "f1ffffff00000000000000000000000090010000000000cc000000004f00700065006e002000530061006e00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "SmCaptionFont" /t REG_BINARY /d "f1ffffff00000000000000000000000090010000000000cc000000004f00700065006e002000530061006e00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "StatusFont" /t REG_BINARY /d "f3ffffff00000000000000000000000090010000000000cc000000004f00700065006e002000530061006e00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1

	reg add "HKU\%usersid%\Control Panel\Desktop\WindowMetrics" /v "CaptionFont" /t REG_BINARY /d "F3FFFFFF00000000000000000000000090010000000000CC000000004F00700065006E002000530061006E00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKU\%usersid%\Control Panel\Desktop\WindowMetrics" /v "IconFont" /t REG_BINARY /d "F3FFFFFF00000000000000000000000090010000000000CC000000004F00700065006E002000530061006E00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKU\%usersid%\Control Panel\Desktop\WindowMetrics" /v "MenuFont" /t REG_BINARY /d "F3FFFFFF00000000000000000000000090010000000000CC000000004F00700065006E002000530061006E00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKU\%usersid%\Control Panel\Desktop\WindowMetrics" /v "MessageFont" /t REG_BINARY /d "F1FFFFFF00000000000000000000000090010000000000CC000000004F00700065006E002000530061006E00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKU\%usersid%\Control Panel\Desktop\WindowMetrics" /v "SmCaptionFont" /t REG_BINARY /d "F3FFFFFF00000000000000000000000090010000000000CC000000004F00700065006E002000530061006E00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
	reg add "HKU\%usersid%\Control Panel\Desktop\WindowMetrics" /v "StatusFont" /t REG_BINARY /d "F3FFFFFF00000000000000000000000090010000000000CC000000004F00700065006E002000530061006E00730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >nul 2>&1
)
set /a TweaksCounter+=13

rem Window Borders - zero width
reg add "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" /v "BorderWidth" /t REG_SZ /d "-15" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" /v "PaddedBorderWidth" /t REG_SZ /d "0" /f >nul 2>&1

rem Wallpaper Quality - 100 percent
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d 100 /f >nul 2>&1

rem Page Priority setting for Torrent apps
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\utorrent.exe\PerfOptions" /v "PagePriority" /t REG_DWORD /d 00000001 /f >nul 2>&1
set /a TweaksCounter+=5
call :updatescreen

rem Taskbar - Thumbnails - bigger size + shorter spacing + faster appearing
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "BottomMarginPx" /t REG_DWORD /d 00000004 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "LeftMarginPx" /t REG_DWORD /d 00000004 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "MinThumbSizePx" /t REG_DWORD /d 00000400 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "RightMarginPx" /t REG_DWORD /d 00000004 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "ThumbSpacingXPx" /t REG_DWORD /d 00000004 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "ThumbSpacingYPx" /t REG_DWORD /d 00000004 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "TopMarginPx" /t REG_DWORD /d 00000004 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ExtendedUIHoverTime" /t REG_DWORD /d 0000000a /f >nul 2>&1
set /a TweaksCounter+=8
call :updatescreen

rem Files explorer and Start Menu settings
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_SearchFiles" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AutoCheckSelect" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisablePreviewDesktop" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DontPrettyPath" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Filter" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideIcons" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "MapNetDrvBtn" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "MMTaskbarGlomLevel" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ReindexedProfile" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ServerAdminUI" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShellMigrationLevel" /t REG_DWORD /d 00000003 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCompColor" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowInfoTip" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowStatusBar" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTypeOverlay" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_IrisRecommendations" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_Layout" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StartMenuInit" /t REG_DWORD /d 0000000d /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StartMigratedBrowserPin" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StartShownOnUpgrade" /t REG_DWORD /d 00000001 /f >nul 2>&1

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_SearchFiles" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AutoCheckSelect" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisablePreviewDesktop" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DontPrettyPath" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Filter" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideIcons" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "MapNetDrvBtn" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "MMTaskbarGlomLevel" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ReindexedProfile" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ServerAdminUI" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShellMigrationLevel" /t REG_DWORD /d 00000003 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCompColor" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowInfoTip" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowStatusBar" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTypeOverlay" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_IrisRecommendations" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_Layout" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StartMenuInit" /t REG_DWORD /d 0000000d /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StartMigratedBrowserPin" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StartShownOnUpgrade" /t REG_DWORD /d 00000001 /f >nul 2>&1

rem adding shortcut for Local Group Policy Editor in Start Menu (to pin it in Start Menu)
if not exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows System\" (
	md "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\" >nul 2>&1
)
powershell.exe "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Local Group Policy Editor.lnk');$s.TargetPath='c:\windows\system32\mmc.exe';$s.Arguments='c:\windows\system32\gpedit.msc';$s.IconLocation='C:\Windows\System32\gpedit.dll';$s.WorkingDirectory='%~dp0';$s.WindowStyle=7;$s.Save()"

set /a TweaksCounter+=29
call :updatescreen

Reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Start" /v "VisiblePlaces" /t REG_BINARY /d "86087352aa5143429f7b2776584659d4ced5342d5afa434582f222e6eaf7773c2fb367e3de895543bfce61f37b18a937bc248a140cd68942a0806ed9bba24882" /f >nul 2>&1

rem remove Edge shortcut and desktop.ini files from Desktop
del /s /a "%userprofile%\Desktop\desktop.ini" >nul 2>&1
del /s /a "C:\Users\Public\Desktop\desktop.ini" >nul 2>&1
del /f /q "C:\Users\Public\Desktop\Microsoft Edge.lnk" >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen

rem taskbar allign leftrem  reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 00000000 /f >nul 2>&1

reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAutoHideInTabletMode" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSizeMove" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSmallIcons" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSn" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarStateLastRun"=hex:b4,ab,36,65,00,00,00,00 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "WinXMigrationLevel" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\StartMode" /v "ActualStartMode" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v "TaskbarEndTask" /t REG_DWORD /d "1" /f >nul 2>&1

rem taskbar allign leftrem  reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAutoHideInTabletMode" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSizeMove" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSmallIcons" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSn" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarStateLastRun"=hex:b4,ab,36,65,00,00,00,00 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "WinXMigrationLevel" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\StartMode" /v "ActualStartMode" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v "TaskbarEndTask" /t REG_DWORD /d "1" /f >nul 2>&1
set /a TweaksCounter+=10
call :updatescreen


rem unpin some shell folders from "This PC"

rem unpin music folder
rem Reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f >nul 2>&1
rem Reg.exe delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usesid%\Software\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Classes\WOW6432Node\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Classes\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
rem unpin Desktop folder
rem Reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f >nul 2>&1
rem Reg.exe delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usesid%\Software\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Classes\WOW6432Node\CLSID\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Classes\CLSID\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
rem unpin Videos folder
rem Reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f >nul 2>&1
rem Reg.exe delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usesid%\Software\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Classes\WOW6432Node\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Classes\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
rem unpin Network shell folder
rem Reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f02c1a0d-be21-4350-88b0-7367fc96ef3c}" /f >nul 2>&1
rem Reg.exe delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f02c1a0d-be21-4350-88b0-7367fc96ef3c}" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{f02c1a0d-be21-4350-88b0-7367fc96ef3c}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKEY_USERS\%usesid%\Software\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{f02c1a0d-be21-4350-88b0-7367fc96ef3c}" /t REG_SZ /d "" /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Classes\WOW6432Node\CLSID\{f02c1a0d-be21-4350-88b0-7367fc96ef3c}" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
Reg.exe add "HKU\%usersid%\Software\Classes\CLSID\{f02c1a0d-be21-4350-88b0-7367fc96ef3c}" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1

rem unpin removable drives
Reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders" /v "{f5fb2c77-0e2f-4a16-a381-3e560c68bc83}" /f >nul 2>&1

set /a TweaksCounter+=5
call :updatescreen

rem File Explorer - increase icons cache
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "MaxCachedIcons" /t REG_SZ /d "4096" /f >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen

rem detailed view for dialog box "Open" and "Save"
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CIDOpen\Modules\GlobalSettings\ProperTreeModuleInner" /v "ProperTreeModuleInner" /t REG_BINARY /d "ba000000" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CIDOpen\Modules\GlobalSettings\Sizer" /v "ProperTreeExpandoSizer" /t REG_BINARY /d "ba0000000100000000000000" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CIDOpen\Modules\GlobalSettings\Sizer" /v "PageSpaceControlSizer" /t REG_BINARY /d "cf0000000100000000000000" /f >nul 2>&1

rem faster mouse wheel scrolling
reg add "HKEY_USERS\%usersid%\Control Panel\Desktop" /v "WheelScrollChars" /t REG_SZ /d "7" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Control Panel\Desktop" /v "WheelScrollLines" /t REG_SZ /d "7" /f >nul 2>&1
rem disable Enhance pointer precision 
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1

set /a TweaksCounter+=5
call :updatescreen


rem Settings - Notifications - Additional settings: disable reminder "let's customize your experience" forcing to sign-in into MS-account and disable new features tutorials after updates
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1

rem Sign-In Screen - Tweaks
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /v "DisableAcrylicBackgroundOnLogon" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "ScreenSaverGracePeriod" /t REG_DWORD /d 00000007 /f >nul 2>&1
set /a TweaksCounter+=6
call :updatescreen

rem Do not show a warning when leaving Msconfig
Reg.exe add "HKCU\Software\Microsoft\Shared Tools\MsConfig" /v "NoRebootUI" /t REG_DWORD /d "1" /f >nul 2>&1

rem show this pc on desktop
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f >nul 2>&1

rem File Explorer - Open This PC instead of Libraries
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 00000001 /f >nul 2>&1

rem File Explorer - Enable Search Text Auto Completion
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "Append Completion" /t REG_SZ /d "yes" /f >nul 2>&1

rem Error Reporting - Disable
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 00000001 /f >nul 2>&1
rem Desktop Windows - Disable Aero Shake
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d 00000001 /f >nul 2>&1
rem Created Shortcut Name - Remove Prefix
reg delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "ShortcutNameTemplate" /f >nul 2>&1
rem Control Userpasswords2 - Reveal Auto Logon Checkbox
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" /v "DevicePasswordLessBuildVersion" /t REG_DWORD /d 00000000 /f >nul 2>&1
rem Ads and Suggestions - Disable
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.InputSwitchToastHandler" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314563Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
rem Administrative shares - Disable
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareWks" /t REG_DWORD /d 00000000 /f >nul 2>&1
set /a TweaksCounter+=24
call :updatescreen


rem slighly warmer and less blinding colors for classic windows elements
Reg.exe add "HKCU\Control Panel\Colors" /v "ButtonFace" /t REG_SZ /d "244 244 241" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Colors" /v "InfoWindow" /t REG_SZ /d "244 244 241" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Colors" /v "Menu" /t REG_SZ /d "244 244 241" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Colors" /v "MenuBar" /t REG_SZ /d "244 244 241" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Colors" /v "Window" /t REG_SZ /d "244 244 241" /f >nul 2>&1
set /a TweaksCounter+=5
call :updatescreen


rem upload on Imgur.com
if exist "C:\pro\_net\Upload-Imgur\imgurUp.exe" (
	Reg.exe add "HKCR\SystemFileAssociations\.bmp\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.bmp\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.bmp\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.gif\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.gif\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.gif\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.jpeg\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.jpeg\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.jpeg\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.jpg\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.jpg\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.jpg\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.png\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.png\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCR\SystemFileAssociations\.png\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.bmp\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.bmp\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.bmp\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.gif\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.gif\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.gif\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpeg\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpeg\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpeg\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpg\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpg\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpg\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.png\shell\UploadOnImgur" /v "Extended" /t REG_SZ /d "" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.png\shell\UploadOnImgur" /v "Icon" /t REG_SZ /d "C:\pro\_net\Upload-Imgur\imgurUp.exe" /f >nul 2>&1
	Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.png\shell\UploadOnImgur\command" /ve /t REG_SZ /d "\"C:\pro\_net\Upload-Imgur\imgurUp.exe\" \"%%1\"" /f >nul 2>&1

	if UILanguage==0419 (
		Reg.exe add "HKCR\SystemFileAssociations\.bmp\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCR\SystemFileAssociations\.gif\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCR\SystemFileAssociations\.jpeg\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCR\SystemFileAssociations\.jpg\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCR\SystemFileAssociations\.png\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.bmp\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.gif\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpeg\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpg\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.png\shell\UploadOnImgur" /ve /t REG_SZ /d "Загрузить на imgur" /f >nul 2>&1
	) else (
		Reg.exe add "HKCR\SystemFileAssociations\.bmp\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCR\SystemFileAssociations\.gif\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCR\SystemFileAssociations\.jpeg\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCR\SystemFileAssociations\.jpg\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCR\SystemFileAssociations\.png\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.bmp\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.gif\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpeg\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.jpg\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
		Reg.exe add "HKCU\Software\Classes\SystemFileAssociations\.png\shell\UploadOnImgur" /ve /t REG_SZ /d "Upload on Imgur" /f >nul 2>&1
	)
)
set /a TweaksCounter+=5
call :updatescreen

@echo.
call :PrintLineNum 11

rem applying all changes made to system policy
gpupdate /force >nul 2>&1

rem Search settings
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "SafeSearchMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\0" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\1" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\2" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\3" /v "Include" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\4" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\5" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\6" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\7" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\8" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\9" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\10" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\11" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\12" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\13" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\14" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\15" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\16" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\17" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\DefaultRules\18" /v "Include" /t REG_DWORD /d "0" /f >nul 2>&1
set /a TweaksCounter+=21
call :updatescreen

@echo.
@echo.
call :PrintLineNum 6
call :PrintLineNum 7
@echo.
@echo.
if [%1]==[] pause
exit /b


:updatescreen
cls
@echo.
@echo [ %TweaksCounter% -- ~%TweaksAmount% ]
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


:GetDateTime
set datetime=(%DATE%)-(%TIME%)
set datetime=%datetime:/=0%
set datetime=%datetime::=0%
exit /b


:CheckTranslastionFileAvailable
rem set English language if language file was not found
if not exist "%~dp0_translations\messages_%UILanguage%.txt" (
	set UILanguage=0409
)
:eof
exit /b