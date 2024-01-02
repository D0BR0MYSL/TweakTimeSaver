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
call :PrintLineNum 48
call :PrintLineNum 49
call :PrintLineNum 50
call :PrintLineNum 51
@echo.
call :PrintLineNum 53
call :PrintLineNum 54
call :PrintLineNum 55
call :PrintLineNum 56
call :PrintLineNum 57
call :PrintLineNum 58
call :PrintLineNum 59
call :PrintLineNum 60
@echo.
call :PrintLineNum 62
@echo.
@echo.
@echo.
call :PrintLineNum 9
@echo.
@echo.
if [%1]==[] pause >nul 2>&1
if [%1]==[] pause

rem getting User SID
for /F "tokens=2" %%i in ('whoami /user /fo table /nh') do set usersid=%%i

rem getting User account name 
for /f "delims=" %%i in ('wmic useraccount get name^,sid ^| findstr /vi "SID"') do @for /F %%a in ("%%i") do if exist "C:\users\%%a" set buffer=%%i
set username=%buffer:~0,18%
set username=%username: =%

set datetime=

cls
@echo.
call :PrintLineNum 10
%SystemRoot%\System32\CScript.exe "%~dp0_tools\_apps\create-restore-point\create-restore-point.vbs"

rem deploying additional Group Policy applets from Microsoft
if not exist %SystemDrive%\Windows\PolicyDefinitions\msedge.admx (
	xcopy "%~dp0_tools\_apps\lgpo\Microsoft Edge additional Group Policy applets\*.*" "%SystemDrive%\Windows\PolicyDefinitions\" /S/E/F/Y >nul 2>&1
)

rem waiting 6 seconds for restore point creation in background
ping localhost -n 6 >nul 2>&1

rem creating backup in _user-files folder
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /b "%~dp0_user-files\_tweaks\_group-policy-bakups"

cls
@echo.
call :PrintLineNum 11

"%~dp0_tools\_apps\PowerRun\PowerRun.exe" "Reg.exe" add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d "0x0" /f >nul 2>&1

rem restoring local group policy predefined profile
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /m "%~dp0_tools\_apps\lgpo\security_apply.pol" >nul 2>&1
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /ua "%~dp0_tools\_apps\lgpo\security_apply.pol" >nul 2>&1
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /u:%username% "%~dp0_tools\_apps\lgpo\security_apply.pol" >nul 2>&1
gpupdate /force >nul 2>&1

rem adding official Edge applets (from Microsoft) into Group Policy instrumentation
xcopy "%~dp0_tools\_apps\lgpo\Microsoft Edge additional Group Policy applets\" "%SystemDrive%\Windows\PolicyDefinitions\" /S/E/F/Y >nul 2>&1

REM ;Windows 11 Disable Virtualization Based Security
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "0" /f >nul 2>&1

rem disable UAC
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "0x0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorUser" /t REG_DWORD /d "0x3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d "0x0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "FilterAdministratorToken" /t REG_DWORD /d "0x0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d "0x0" /f >nul 2>&1

rem disable encrypting of paging file
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Policies" /v "NtfsEncryptPagingFile" /t REG_DWORD /d "0x0" /f >nul 2>&1

rem disable security maintrance notifications
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1

rem  Allow launch of "unsafe" files downloaded from the Internet
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /V "1806" /T "REG_DWORD" /D "00000000" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /V "1806" /T "REG_DWORD" /D "00000000" /f >nul 2>&1
rem  Disable file security check and do not display a warning window
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Security" /V "DisableSecuritySettingsCheck" /T "REG_DWORD" /D "00000001" /f >nul 2>&1

rem disable protection from Spectre and Meltdown threats
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f >nul 2>&1 >nul
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 3 /f >nul 2>&1 >nul


REM ;Do not check the digital signature of downloaded programs
Reg.exe add "HKCU\Software\Microsoft\Internet Explorer\Download" /v "CheckExeSignatures" /t REG_SZ /d "no" /f >nul 2>&1
REM ;Run programs with unverified digital signature
Reg.exe add "HKCU\Software\Microsoft\Internet Explorer\Download" /v "RunInvalidSignatures" /t REG_DWORD /d "1" /f >nul 2>&1


rem disable drivers signature check
bcdedit.exe /set loadoptions DISABLE_INTEGRITY_CHECKS >nul 2>&1
"%~dp0_tools\_apps\PowerRun\PowerRun.exe" bcdedit.exe /set NOINTEGRITYCHECKS ON >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Driver Signing" /v "Policy" /t REG_BINARY /d "00" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Non-Driver Signing" /v "Policy" /t REG_BINARY /d "00" /f >nul 2>&1
Reg.exe add "HKCU\Software\Policies\Microsoft\Windows NT\Driver Signing" /v "BehaviorOnFailedVerify" /t REG_DWORD /d "0x0" /f >nul 2>&1

rem disable windows defender scheduled tasks
schtasks /Change /tn "\Microsoft\Windows\AppID\SmartScreenSpecific" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /DISABLE >nul 2>&1

rem disdable Windows Defender
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0x0" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "AllowFastServiceStartup" /t REG_DWORD /d "0x0" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "LocalSettingOverrideSpynetReporting" /t REG_DWORD /d "0x0" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "0x2" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpEngine" /t REG_DWORD /d "0x0" /f >nul 2>&1
reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f >nul 2>&1

rem disable smartscreen for edge browser
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1 
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0x0" /f >nul 2>&1
reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0x0" /f >nul 2>&1
reg.exe add "HKCU\SOFTWARE\Microsoft\Edge\SmartScreenEnabled" /v "@" /t REG_DWORD /d "0x0" /f >nul 2>&1

rem developer settings - powershell execution policy
reg.exe add "HKEY_USERS\%usersid%\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "RemoteSigned" /f >nul 2>&1
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "RemoteSigned" /f >nul 2>&1

rem  Disable security warning when opening some of files types
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d "0x1" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /t REG_SZ /d ".7z; .zip; .rar; .tar; .gz; .nfo; .txt; .exe; .bat; .com; .cmd; .reg; .msi; .htm; .html; .gif; .bmp; .jpg; .avi; .mpg; .mpeg; .mov; .mp3; .m3u; .wav; .mdb; .exe; *.txt; .png; .pdf; .zip; .7z; .rar; .jpg; .webp; .html; .bat; .cmd; .js; *.msc;" /f >nul 2>&1
reg add "HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /t REG_SZ /d ".7z; .zip; .rar; .tar; .gz; .nfo; .txt; .exe; .bat; .com; .cmd; .reg; .msi; .htm; .html; .gif; .bmp; .jpg; .avi; .mpg; .mpeg; .mov; .mp3; .m3u; .wav; .mdb; .exe; *.txt; .png; .pdf; .zip; .7z; .rar; .jpg; .webp; .html; .bat; .cmd; .js; *.msc;" /f >nul 2>&1
reg add "HKEY_USERS\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /t REG_SZ /d ".7z; .zip; .rar; .tar; .gz; .nfo; .txt; .exe; .bat; .com; .cmd; .reg; .msi; .htm; .html; .gif; .bmp; .jpg; .avi; .mpg; .mpeg; .mov; .mp3; .m3u; .wav; .mdb; .exe; *.txt; .png; .pdf; .zip; .7z; .rar; .jpg; .webp; .html; .bat; .cmd; .js; *.msc;" /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /t REG_SZ /d ".7z; .zip; .rar; .tar; .gz; .nfo; .txt; .exe; .bat; .com; .cmd; .reg; .msi; .htm; .html; .gif; .bmp; .jpg; .avi; .mpg; .mpeg; .mov; .mp3; .m3u; .wav; .mdb; .exe; *.txt; .png; .pdf; .zip; .7z; .rar; .jpg; .webp; .html; .bat; .cmd; .js; *.msc;" /f >nul 2>&1

gpupdate /force >nul 2>&1

rem Windows Terminal or ver.Preview - elevate state always enabled
if exist %userprofile%\AppData\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\wt.exe (
	@echo {} > %userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\elevated-state.json
	"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState" --fileMask "settings.json" --find """elevate"": false," --replace """elevate"": true,"
)
if exist %userprofile%\AppData\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe (
	@echo {} > %userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\elevated-state.json
	"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" --fileMask "settings.json" --find """elevate"": false," --replace """elevate"": true,"
)
cls

@echo.
@echo.
@echo.
call :PrintLineNum 6
call :PrintLineNum 7
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