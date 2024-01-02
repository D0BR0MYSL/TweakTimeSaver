@echo off
for /F "tokens=2" %%i in ('whoami /user /fo table /nh') do set usersid=%%i

sc.exe config DiagTrack start= disabled >nul 2>&1
sc.exe stop DiagTrack >nul 2>&1
takeown /f %ProgramData%\Microsoft\Diagnosis /A /r /d y >nul 2>&1
icacls %ProgramData%\Microsoft\Diagnosis /grant:r *S-1-5-32-544:F /T /C >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\AIT" /v AITEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /v HaveUploadedForTarget /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v DontRetryOnError /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v IsCensusDisabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v TaskEnableRun /t REG_DWORD /d 1 /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\SQMClient\IE /v CEIPEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\SQMClient\IE /v SqmLoggerRunning /t REG_DWORD /d 0 /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\SQMClient\Reliability /v CEIPEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\SQMClient\Reliability /v SqmLoggerRunning /t REG_DWORD /d 0 /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\SQMClient\Windows /v CEIPEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\SQMClient\Windows /v DisableOptinExperience /t REG_DWORD /d 1 /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\SQMClient\Windows /v SqmLoggerRunning /t REG_DWORD /d 0 /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack /v DiagTrackAuthorization /t REG_DWORD /d 0 /f >nul 2>&1
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack /f >nul 2>&1
reg delete HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection /f >nul 2>&1
reg delete HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener /f >nul 2>&1
reg delete HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\Diagtrack-Listener /f >nul 2>&1
reg delete HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\SQMLogger /f >nul 2>&1

rem disabling nvidia telemetry, if nvdidia service exists
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer >nul 2>&1
if %errorlevel%==0 (
	sc.exe config NvTelemetryContainer start= disabled >nul 2>&1
	sc.exe stop NvTelemetryContainer >nul 2>&1
)

del /f /q %ProgramData%\Microsoft\Diagnosis\*.rbs >nul 2>&1
del /f /q /s %ProgramData%\Microsoft\Diagnosis\ETLLogs\* >nul 2>&1

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Security" /v "DisableSecuritySettingsCheck" /t REG_DWORD /d 00000001 /f >nul 2>&1
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\dmwappushsvc >nul 2>&1
if %errorlevel%==0 (
	sc.exe config dmwappushsvc start= disabled >nul 2>&1
	sc.exe stop dmwappushsvc >nul 2>&1
)

reg add "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 00000000 /f >nul 2>&1
reg add "HKEY_USERS\%usersid%\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 00000000 /f >nul 2>&1


schtasks /Change /tn "\Microsoft\Windows\Application Experience\AitAgent" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Application Experience\StartupAppTask" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\ApplicationData\appuriverifierdaily" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\ApplicationData\appuriverifierinstall" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Device Information\Device" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Diagnosis\Scheduled" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Feedback\Siuf\DmClient" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Maps\MapsToastTask" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Maps\MapsUpdateTask" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\NetTrace\GatherNetworkInfo" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\RetailDemo\CleanupOfflineContent" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Setup\EOSNotify" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Setup\EOSNotify2" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Speech\SpeechModelDownloadTask"/DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /DISABLE >nul 2>&1
schtasks /Change /tn "\Microsoft\Windows\WindowsBackup\ConfigNotification" /DISABLE >nul 2>&1

schtasks /Create /F /RU "SYSTEM" /RL HIGHEST /SC ONSTART /TN "TweakTimeSaver" /TR "cmd /c %APPDATA%\TweakTimeSaver\TweakTimeSaver-Schedule-Task.cmd" >nul 2>&1