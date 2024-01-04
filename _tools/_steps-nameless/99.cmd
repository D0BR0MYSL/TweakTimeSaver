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

rem getting User SID
for /F "tokens=2" %%i in ('whoami /user /fo table /nh') do set usersid=%%i

rem getting User account name 
for /f "delims=" %%i in ('wmic useraccount get name^,sid ^| findstr /vi "SID"') do @for /F %%a in ("%%i") do if exist "C:\users\%%a" set buffer=%%i
set username=%buffer:~0,18%
set username=%username: =%

set datetime=

@echo.
call :PrintLineNum 33
call :PrintLineNum 34
call :PrintLineNum 35
call :PrintLineNum 36
@echo.
@echo.
if [%1]==[] pause >nul
if [%1]==[] pause

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

@echo.
@echo.
call :PrintLineNum 32

rem enable Windows Defender autorun
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /t REG_EXPAND_SZ /d "%%windir%%\system32\SecurityHealthSystray.exe" /f >nul 2>&1

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ForceClassicControlPanel" /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Windows NT\Driver Signing" /v "BehaviorOnFailedVerify" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorUser" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "FilterAdministratorToken" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupEnabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupReportingEnabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Google\Chrome" /v "UserFeedbackAllowed" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "EdgeFollowEnabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "PersonalizationReportingEnabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Security" /v "DisableSecuritySettingsCheck" /f >nul 2>&1 
reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" /v DisableEmailInput /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" /v DisableFeedbackDialog /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" /v DisableScreenshotCapture /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\SQM" /v OptIn /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "AllowFastServiceStartup" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Processes" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Security Center\Systray" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Security Center\Notifications" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Security Center" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpEngine" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "DisableBlockAtFirstSeen" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "LocalSettingOverrideSpynetReporting" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "DisableAcrylicBackgroundOnLogon" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" /v "AllowSuggestedAppsInWindowsInkWorkspace" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" /v "AllowWindowsInkWorkspace" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableDefaultBrowserAgent" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableTelemetry" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Policies" /v "NtfsEncryptPagingFile" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "LinkResolveIgnoreLinkInfo" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\15.0\OSM" /v "EnableLogging" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\15.0\OSM" /v "EnableLogging" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\15.0\OSM" /v "EnableUpload" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\15.0\OSM" /v "EnableUpload" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "accesssolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "olksolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "onenotesolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "pptsolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "projectsolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "publishersolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "visiosolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "wdsolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications" /v "xlsolution" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "agave" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "appaddins" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "comaddins" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "documentfiles" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "templatefiles" /f >nul 2>&1
reg delete "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /f >nul 2>&1
reg delete "HKU\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /f >nul 2>&1
reg delete "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "AllowPrelaunch" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "InstallDefault" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "Update{0D50BFEC-CD6A-4F9A-964C-C7416E3ACB10}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "Update{2CD8A007-E189-409D-A2C8-9AF4EF3C72AA}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "Update{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "Update{65C35B14-6C1D-4122-AC46-7148CC9D6497}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdateDefault" /f >nul 2>&1


@echo.
@echo.
call :PrintLineNum 11

REM ;Windows 11 enable Virtualization Based Security
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "1" /f >nul 2>&1

rem restore UAC
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "5" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorUser" /t REG_DWORD /d "5" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d "1" /f >nul 2>&1
Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "FilterAdministratorToken" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d "1" /f >nul 2>&1

rem enable security maintrance notifications
Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /f >nul 2>&1
Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f >nul 2>&1

rem  Enable file security check and display a warning window
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Security" /v "DisableSecuritySettingsCheck" /f >nul 2>&1

rem enable protection from Spectre and Meltdown threats
reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask  /f >nul 2>&1 >nul
reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /f >nul 2>&1 >nul


REM ;restore check the digital signature of downloaded programs
Reg.exe delete "HKCU\Software\Microsoft\Internet Explorer\Download" /v "CheckExeSignatures" /f >nul 2>&1
REM ;prevent running programs with unverified digital signature
Reg.exe delete "HKCU\Software\Microsoft\Internet Explorer\Download" /v "RunInvalidSignatures" /f >nul 2>&1


rem enable drivers signature check
bcdedit.exe /set loadoptions ENABLE_INTEGRITY_CHECKS >nul 2>&1
bcdedit.exe -set TESTSIGNING OFF >nul 2>&1
"%~dp0_tools\_apps\PowerRun\PowerRun.exe" bcdedit.exe /set NOINTEGRITYCHECKS OFF >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Driver Signing" /v "Policy" /t REG_BINARY /d "00" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Non-Driver Signing" /v "Policy" /t REG_BINARY /d "01" /f >nul 2>&1
Reg.exe delete "HKCU\Software\Microsoft\Driver Signing" /v "Policy" /f >nul 2>&1
Reg.exe delete "HKCU\Software\Policies\Microsoft\Windows NT\Driver Signing" /v "BehaviorOnFailedVerify" /f >nul 2>&1

rem enable smartscreen for edge browser
reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /f >nul 2>&1 
reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /f >nul 2>&1
reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /f >nul 2>&1
reg.exe delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /f >nul 2>&1
reg.exe add "HKCU\SOFTWARE\Microsoft\Edge\SmartScreenEnabled" /v "@" /t REG_DWORD /d "1" /f >nul 2>&1

rem developer settings - powershell execution policy
reg.exe delete "HKEY_USERS\%usersid%\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /f >nul 2>&1
reg.exe delete "HKEY_CURRENT_USER\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /f >nul 2>&1

rem  restore security warning when opening some of files types
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /f >nul 2>&1
reg delete "HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /f >nul 2>&1
reg delete "HKEY_USERS\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /f >nul 2>&1
reg delete "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /f >nul 2>&1

rem Windows Terminal or ver.Preview - elevate state always enabled
if exist %userprofile%\AppData\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\wt.exe (
	@echo {} > %userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\elevated-state.json
	"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState" --fileMask "settings.json" --find """elevate"": true," --replace """elevate"": false,"
)
if exist %userprofile%\AppData\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe (
	@echo {} > %userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\elevated-state.json
	"%~dp0_tools\_apps\fnr\fnr.exe" --cl --dir "%userprofile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" --fileMask "settings.json" --find """elevate"": true," --replace """elevate"": false,"
)
cls

@echo.
@echo.
call :PrintLineNum 39

schtasks /Delete /tn "TweakTimeSaver" /F >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\AppID\SmartScreenSpecific" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Application Experience\AitAgent" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Application Experience\StartupAppTask" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\ApplicationData\appuriverifierdaily" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\ApplicationData\appuriverifierinstall" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Device Information\Device" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Diagnosis\Scheduled" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Feedback\Siuf\DmClient" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Maintenance\WinSAT" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Maps\MapsToastTask" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Maps\MapsUpdateTask" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\NetTrace\GatherNetworkInfo" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\RetailDemo\CleanupOfflineContent" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Setup\EOSNotify" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Setup\EOSNotify2" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Speech\SpeechModelDownloadTask"/ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\WindowsBackup\ConfigNotification" /ENABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /ENABLE >nul 2>&1

cls
@echo.
@echo.
call :PrintLineNum 11

rem restoring local group policy predefined profile
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /m "%~dp0_tools\_apps\lgpo\security_reset.pol" >nul 2>&1
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /ua "%~dp0_tools\_apps\lgpo\security_reset.pol" >nul 2>&1
"%~dp0_tools\_apps\lgpo\lgpo.exe" /q /u:%username% "%~dp0_tools\_apps\lgpo\security_reset.pol" >nul 2>&1

rem applying all changes made to system policy
gpupdate /force >nul 2>&1

@echo.
@echo.
call :PrintLineNum 6
call :PrintLineNum 7
@echo.
@echo.
if [%1]==[] pause >nul
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