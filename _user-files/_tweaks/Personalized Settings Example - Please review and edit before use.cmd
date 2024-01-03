@echo off

for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CONTROLSET001\CONTROL\NLS\Language" /v Installlanguage') do set UILanguage=%%a
if %UILanguage%==0419 (
	chcp 1251
) else (
	chcp 65001
)
>NUL 2>&1 REG QUERY "HKU\S-1-5-19" ||(
	echo.
	Please run this file with Administrator rights
 	echo.
	pause >nul
	pause
	exit
)

cls
@echo.
@echo Ready to start?
@echo.
@echo.
pause

@echo on

rem getting User SID
for /F "tokens=2" %%i in ('whoami /user /fo table /nh') do set usersid=%%i

rem getting User account name 
for /f "delims=" %%i in ('wmic useraccount get name^,sid ^| findstr /vi "SID"') do @for /F %%a in ("%%i") do if exist "C:\users\%%a" set buffer=%%i
set username=%buffer:~0,18%
set username=%username: =%

rem copy Edge settings file having some defaults for convenience
xcopy "..\..\_user-files\_apps\_browsers\Edge-new-default-settings\Preferences" "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\" /S/E/F/Y
xcopy "..\..\_user-files\_apps\_browsers\Edge-new-default-settings\Preferences" "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Profile 1\" /S/E/F/Y

rem Disable Work folders (comrporative netweork fearure)
dism /online /NoRestart /Disable-Feature /FeatureName:WorkFolders-Client >nul 2>&1
set /a TweaksCounter+=1
call :updatescreen

rem convenient date format for long date
Reg.exe add "HKCU\Control Panel\International" /v "sLongDate" /t REG_SZ /d "yyyy.MM.dd" /f >nul 2>&1

rem remove unused apps from Windows Store
powershell.exe -file "..\..\_tools\_tweaks\windows-store-apps--remove-unused-English.ps1"

rem keyboard Preload usersid - for Russian keyboard
rem reg add "HKEY_USERS\%usersid%\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
rem reg add "HKEY_USERS\%usersid%\Keyboard Layout\Preload" /v "2" /t REG_SZ /d "00000419" /f >nul 2>&1
rem reg add "HKEY_CURRENT_USER\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
rem reg add "HKEY_CURRENT_USER\Keyboard Layout\Preload" /v "2" /t REG_SZ /d "00000419" /f >nul 2>&1
rem reg add "HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
rem reg add "HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" /v "2" /t REG_SZ /d "00000419" /f >nul 2>&1
rem "..\..\_tools\_apps\PowerRun\PowerRun.exe" "reg.exe" add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemProtectedUserData\%usersid%\AnyoneRead\LanguageProfile" /v "Profile" /t REG_SZ /d "User Profile#Languages+Men-US@ru@&ShowAutoCorrection+D1&ShowTextPrediction+D1&ShowCasing+D1&ShowShiftLock+D1&WindowsOverride+Sru%%User Profile/en-US#0409:00000409+D1&CachedLanguageName+S@Winlangdb.dll,-1121%%User Profile/ru#0419:00000419+D1&CachedLanguageName+S@Winlangdb.dll,-1390" /f >nul 2>&1
rem 

rem disable lock screen with slideshow
"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Lock Screen" /v "SlideshowEnabled" /t REG_DWORD /d "0" /f
"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreen" /t REG_DWORD /d 00000001 /f
REM ; 100% DPI
Reg.exe add "HKCU\Control Panel\Desktop" /v "LogPixels" /t REG_DWORD /d "150" /f
Reg.exe add "HKCU\Control Panel\Desktop" /v "Win8DpiScaling" /t REG_DWORD /d "0" /f
Reg.exe delete "HKCU\Control Panel\Desktop\PerMonitorSettings" /f
Reg.exe add "HKCU\Control Panel\Desktop\WindowMetrics" /v "AppliedDPI" /t REG_DWORD /d "150" /f

rem Explorer - remove Libraries
rem Reg.exe delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" /f
REM ; Disable cloud content search for microsoft account
::Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsMSACloudSearchEnabled" /t REG_DWORD /d "0" /f
rem MS Edge Browser - disable side bar
rem Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" /t REG_DWORD /d 0 /f
rem Disable Offline files
::Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" /v "AllowOfflineFilesforCAShares" /t REG_DWORD /d 0 /f
::Reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" /v "OnlineCachingLatencyThreshold" /f
::Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\NetCache" /v "WorkOfflineDisabled" /t REG_DWORD /d 1 /f
::Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\NetCache" /v "NoMakeAvailableOffline" /t REG_DWORD /d 1 /f
rem File Explorer - remove Quick Access Hub
rem "..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "HubMode" /t REG_DWORD /d 00000001 /f



rem new defaults for nvidia GeForce Experience settings after first driver installation
rem creating backup of nvidia GeForce Experience settings
rem call :GetDateTime
rem reg export "HKEY_USERS\usersid\Software\NVIDIA Corporation\Global\ShadowPlay\NVSPCAPS" "%~dp0_registry-tweaks\_nvidia-geforce-experience\nvidia-GeForce-Experience-settings-backup_%datetime.reg" /y
rem rem applying new settings
rem copy /Y "%~dp0_registry-tweaks\template-geforceexp.reg" "%~dp0_registry-tweaks\template-geforceexp-%usersid%.reg"
rem "..\..\_tools\_apps\fnr\fnr.exe" --cl --dir "%~dp0_registry-tweaks" --fileMask "template-geforceexp-%usersid%.reg" --find "usersid" --replace "%usersid%"
rem Regedit.exe /S "%~dp0_registry-tweaks\template-geforceexp-%usersid%.reg"
rem if exist "%~dp0_registry-tweaks\template-geforceexp-%usersid%.reg" (
rem 	del /f /q "%~dp0_registry-tweaks\template-geforceexp-%usersid%.reg"
rem )


rem block Internet accsess for desired apps
netsh advfirewall firewall add rule name="C:\pro\_media\_audio\SoundNormalizer\Sound.Normalizer.8.7.Portable.by.Spirit.Summer.exe" dir=in action=block program="C:\pro\_media\_audio\SoundNormalizer\Sound.Normalizer.8.7.Portable.by.Spirit.Summer.exe"
netsh advfirewall firewall add rule name="C:\pro\_media\_audio\SoundNormalizer\Sound.Normalizer.8.7.Portable.by.Spirit.Summer.exe" dir=out action=block


rem disable shared folders and background search over local network
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\HomeGroupListener"
if %errorlevel%==0 (
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" sc.exe config HomeGroupListener start=disabled
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" sc.exe stop HomeGroupListener
)
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\HomeGroupProvider"
if %errorlevel%==0 (
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" sc.exe config HomeGroupProvider start=disabled
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" sc.exe stop HomeGroupProvider
)
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer"
if %errorlevel%==0 (
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d 00000000 /f
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB2" /t REG_DWORD /d 00000000 /f
)
schtasks /Change /tn "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /DISABLE
rem del /f /q "%useprofile%\Desktop\*.lnk"
rem del /f /q "C:\Users\Public\Desktop\*.lnk"
del /f /q "C:\Users\Public\Desktop\Microsoft Edge.lnk"
rem file associations
set IMAGEVIEWER=C:\pro\_media\_image\QuickPictureViewer\quick-picture-viewer.exe
set TEXTEDITOR=c:\pro\_office\akelpad\akelpad.exe
set MUSICPLAYER=C:\Pro\_media\_audio\foobar2000\foobar2000.exe
set VIDEOPLAYER=C:\pro\_media\_video\PotPlayer\PotPlayerMini64.exe
set BOOKREADER=C:\pro\_office\SumatraPDF\SumatraPDF.exe
set ISOEDITOR=C:\pro\_files\UltraISO\UltraISOPortable.exe
if exist "%IMAGEVIEWER%" (
	ftype my_file_jpg="%IMAGEVIEWER%" "%%1"
	assoc .jpg=my_file_jpg
	ftype my_file_jpeg="%IMAGEVIEWER%" "%%1"
	assoc .jpeg=my_file_jpeg
	ftype my_file_png="%IMAGEVIEWER%" "%%1"
	assoc .png=my_file_png
	ftype my_file_bmp="%IMAGEVIEWER%" "%%1"
	assoc .bmp=my_file_bmp
	ftype my_file_gif="%IMAGEVIEWER%" "%%1"
	assoc .gif=my_file_gif
	ftype my_file_tif="%IMAGEVIEWER%" "%%1"
	assoc .tif=my_file_tif
	ftype my_file_tiff="%IMAGEVIEWER%" "%%1"
	assoc .tiff=my_file_tiff
	ftype my_file_webp="%IMAGEVIEWER%" "%%1"
	assoc .webp=my_file_webp
	ftype my_file_arw="%IMAGEVIEWER%" "%%1"
	assoc .arw=my_file_arw
	ftype my_file_psd="%IMAGEVIEWER%" "%%1"
	assoc .psd=my_file_psd
)

if exist %TEXTEDITOR% (
	ftype my_file_lst="%TEXTEDITOR%" "%%1"
	assoc .lst=my_file_lst
	ftype my_file_txt="%TEXTEDITOR%" "%%1"
	assoc .txt=my_file_txt
	ftype my_file_md="%TEXTEDITOR%" "%%1"
	assoc .md=my_file_md
	ftype my_file_css="%TEXTEDITOR%" "%%1"
	assoc .css=my_file_css
	ftype my_file_sh="%TEXTEDITOR%" "%%1"
	assoc .sh=my_file_sh
	ftype my_file_yaml="%TEXTEDITOR%" "%%1"
	assoc .yaml=my_file_yaml
	ftype my_file_mnu="%TEXTEDITOR%" "%%1"
	assoc .mnu=my_file_mnu
	ftype my_file_md5="%TEXTEDITOR%" "%%1"
	assoc .md5=my_file_md5
	ftype my_file_sha="%TEXTEDITOR%" "%%1"
	assoc .sha=my_file_sha
	ftype my_file_sha1="%TEXTEDITOR%" "%%1"
	assoc .sha1=my_file_sha1
	ftype my_file_sha256="%TEXTEDITOR%" "%%1"
	assoc .sha256=my_file_sha256
	ftype my_file_toml="%TEXTEDITOR%" "%%1"
	assoc .toml=my_file_toml
	ftype my_file_psc="%TEXTEDITOR%" "%%1"
	assoc .psc=my_file_psc
	ftype my_file_ini="%TEXTEDITOR%" "%%1"
	assoc .ini=my_file_ini
	ftype my_file_log="%TEXTEDITOR%" "%%1"
	assoc .log=my_file_log
	ftype my_file_xml="%TEXTEDITOR%" "%%1"
	assoc .xml=my_file_xml
	ftype my_file_nfo="%TEXTEDITOR%" "%%1"
	assoc .nfo=my_file_nfo
	ftype my_file_conf="%TEXTEDITOR%" "%%1"
	assoc .conf=my_file_conf
	ftype my_file_cfg="%TEXTEDITOR%" "%%1"
	assoc .cfg=my_file_cfg
	ftype my_file_hpp="%TEXTEDITOR%" "%%1"
	assoc .hpp=my_file_hpp
	ftype my_file_h="%TEXTEDITOR%" "%%1"
	assoc .h=my_file_h
	ftype my_file_cpp="%TEXTEDITOR%" "%%1"
	assoc .cpp=my_file_cpp
	ftype my_file_c="%TEXTEDITOR%" "%%1"
	assoc .c=my_file_c
	ftype my_file_cs="%TEXTEDITOR%" "%%1"
	assoc .cs=my_file_cs
	ftype my_file_lng="%TEXTEDITOR%" "%%1"
	assoc .lng=my_file_lng
	ftype my_file_json="%TEXTEDITOR%" "%%1"
	assoc .json=my_file_json
)

if exist %MUSICPLAYER% (
	ftype my_file_mp3="%MUSICPLAYER%" "%%1"
	assoc .mp3=my_file_mp3
	ftype my_file_flac="%MUSICPLAYER%" "%%1"
	assoc .flac=my_file_flac
	ftype my_file_fla="%MUSICPLAYER%" "%%1"
	assoc .fla=my_file_fla
	ftype my_file_ape="%MUSICPLAYER%" "%%1"
	assoc .ape=my_file_ape
	ftype my_file_wav="%MUSICPLAYER%" "%%1"
	assoc .wav=my_file_wav
	ftype my_file_wma="%MUSICPLAYER%" "%%1"
	assoc .wma=my_file_wma
	ftype my_file_m4a="%MUSICPLAYER%" "%%1"
	assoc .m4a=my_file_m4a
	ftype my_file_ogg="%MUSICPLAYER%" "%%1"
	assoc .ogg=my_file_ogg
	ftype my_file_ac3="%MUSICPLAYER%" "%%1"
	assoc .ac3=my_file_ac3
	ftype my_file_opus="%MUSICPLAYER%" "%%1"
	assoc .opus=my_file_opus
	ftype my_file_dts="%MUSICPLAYER%" "%%1"
	assoc .dts=my_file_dts
	ftype my_file_dtshd="%MUSICPLAYER%" "%%1"
	assoc .dtshd=my_file_dtshd
	ftype my_file_amr="%MUSICPLAYER%" "%%1"
	assoc .amr=my_file_amr
)

if exist %VIDEOPLAYER% (
	ftype my_file_mkv="%VIDEOPLAYER%" "%%1"
	assoc .mkv=my_file_mkv
	ftype my_file_mp4="%VIDEOPLAYER%" "%%1"
	assoc .mp4=my_file_mp4
	ftype my_file_avi="%VIDEOPLAYER%" "%%1"
	assoc .avi=my_file_avi
	ftype my_file_webm="%VIDEOPLAYER%" "%%1"
	assoc .webm=my_file_webm
	ftype my_file_ts="%VIDEOPLAYER%" "%%1"
	assoc .ts=my_file_ts
	ftype my_file_3gp="%VIDEOPLAYER%" "%%1"
	assoc .3gp=my_file_3gp
	ftype my_file_mpg="%VIDEOPLAYER%" "%%1"
	assoc .mpg=my_file_mpg
	ftype my_file_mpeg="%VIDEOPLAYER%" "%%1"
	assoc .mpeg=my_file_mpeg
	ftype my_file_bdmv="%VIDEOPLAYER%" "%%1"
	assoc .bdmv=my_file_bdmv
)


if exist %BOOKREADER% (
	ftype my_file_fb2="%BOOKREADER%" "%%1"
	assoc .fb2=my_file_fb2
	ftype my_file_djvu="%BOOKREADER%" "%%1"
	assoc .djvu=my_file_djvu
	ftype my_file_epub="%BOOKREADER%" "%%1"
	assoc .epub=my_file_epub
)

if exist %ISOEDITOR% (
	ftype my_file_iso="%ISOEDITOR%" "%%1"
	assoc .iso=my_file_iso
	ftype my_file_isz="%ISOEDITOR%" "%%1"
	assoc .isz=my_file_isz
)

rem remove sendTo default shortcuts
del /f /q "%appdata%\Microsoft\Windows\SendTo\Compressed (zipped) Folder.ZFSendToTarget"
del /f /q "%appdata%\Microsoft\Windows\SendTo\Desktop (create shortcut).DeskLink"
del /f /q "%appdata%\Microsoft\Windows\SendTo\Mail Recipient.MAPIMail"
del /f /q "%appdata%\Microsoft\Windows\SendTo\Передача файлов через Bluetooth.LNK"
del /f /q "%appdata%\Microsoft\Windows\SendTo\Bluetooth device.LNK"
del /f /q "%appdata%\Microsoft\Windows\SendTo\Документы.mydocs"
del /f /q "%appdata%\Microsoft\Windows\SendTo\Documents.mydocs"
REM ;Custom screensaver anf its settings
"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKU\%usersid%\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "1" /f
"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKU\%usersid%\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d 0 /f
"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKU\%usersid%\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "420" /f
rem "..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKU\%usersid%\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "C:\Windows\system32\GLOWIN~1.SCR" /f

REM ;disable cloud clipboard
rem "..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 0 /f
rem "..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowClipboardHistory" /t REG_DWORD /d 0 /f
rem "..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowCrossDeviceClipboard" /t REG_DWORD /d 0 /f

REM ;disable My People
::"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d 0 /f

REM ;remove Miracast from PC to another external device
::"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}" /t REG_SZ /d "Play to Menu" /f

rem disable search panel on taskbar and save search - disable
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v "SafeSearchMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKU\%usersid%\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1

REM ;7-Zip settings
reg.exe add "HKCU\Software\7-Zip" /v "Lang" /t REG_SZ /d "ru" /f
reg.exe add "HKCU\Software\7-Zip" /v "LargePages" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\Compression" /v "ShowPassword" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\Compression" /v "Level" /t REG_DWORD /d "5" /f
reg.exe add "HKCU\Software\7-Zip\Compression" /v "Archiver" /t REG_SZ /d "7z" /f
reg.exe add "HKCU\Software\7-Zip\Compression" /v "EncryptHeaders" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\7z" /v "Level" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\7z" /v "Dictionary" /t REG_DWORD /d "262144" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\7z" /v "Order" /t REG_DWORD /d "32" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\7z" /v "BlockSize" /t REG_DWORD /d "26" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\7z" /v "NumThreads" /t REG_DWORD /d "8" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\7z" /v "Method" /t REG_SZ /d "LZMA2" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\7z" /v "Options" /t REG_SZ /d "qs yx=9" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\bzip2" /v "Level" /t REG_DWORD /d "9" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\bzip2" /v "Dictionary" /t REG_DWORD /d "921600" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\bzip2" /v "NumThreads" /t REG_DWORD /d "4" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\gzip" /v "Level" /t REG_DWORD /d "9" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\gzip" /v "Order" /t REG_DWORD /d "258" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\tar" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\xz" /v "Level" /t REG_DWORD /d "9" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\xz" /v "Dictionary" /t REG_DWORD /d "268435456" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\xz" /v "Order" /t REG_DWORD /d "273" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\xz" /v "NumThreads" /t REG_DWORD /d "3" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\xz" /v "Options" /t REG_SZ /d "qs yx=9" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\zip" /v "Level" /t REG_DWORD /d "9" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\zip" /v "Order" /t REG_DWORD /d "258" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\zip" /v "NumThreads" /t REG_DWORD /d "4" /f
reg.exe add "HKCU\Software\7-Zip\Compression\Options\zip" /v "Method" /t REG_SZ /d "Deflate" /f
reg.exe add "HKCU\Software\7-Zip\Extraction" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "ShowDots" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "ShowRealFileIcons" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "FullRow" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "ShowGrid" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "SingleClick" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "AlternativeSelection" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "ShowSystemMenu" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "FolderShortcuts" /t REG_BINARY /d "" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "FlatViewArc0" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "PanelPath1" /t REG_SZ /d "" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "FlatViewArc1" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "ListMode" /t REG_DWORD /d "771" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "Position" /t REG_BINARY /d "6f000000b6000000b90300006203000000000000" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "Panels" /t REG_BINARY /d "01000000000000009a010000" /f
reg.exe add "HKCU\Software\7-Zip\FM" /v "PanelPath0" /t REG_SZ /d "C:\\" /f
reg.exe add "HKCU\Software\7-Zip\FM\Columns" /v "RootFolder" /t REG_BINARY /d "0100000000000000010000000400000001000000a0000000" /f
reg.exe add "HKCU\Software\7-Zip\FM\Columns" /v "FSDrives" /t REG_BINARY /d "0100000000000000010000000400000001000000a00000003800000001000000640000003900000001000000640000001400000001000000640000003b00000001000000640000001800000001000000640000003a0000000100000064000000" /f
reg.exe add "HKCU\Software\7-Zip\FM\Columns" /v "FSFolder" /t REG_BINARY /d "0100000004000000010000000400000001000000830100000700000001000000640000000c00000001000000640000000a00000001000000640000001c00000001000000640000001f00000001000000640000002000000001000000640000000b00000000000000640000000900000000000000640000000800000000000000640000005b0000000000000064000000250000000000000064000000590000000000000064000000" /f
reg.exe add "HKCU\Software\7-Zip\FM\Columns" /v "7-Zip.7z" /t REG_BINARY /d "0100000004000000010000000400000001000000c80100000700000001000000640000000800000001000000640000000c00000001000000640000000900000001000000640000001300000001000000640000000f00000001000000640000001600000001000000640000001b00000001000000640000001f0000000100000064000000200000000100000064000000" /f
reg.exe add "HKCU\Software\7-Zip\FM\Columns" /v "7-Zip.Rar" /t REG_BINARY /d "0100000004000000010000000400000001000000a00000000700000001000000640000000800000001000000640000000c00000001000000640000000a00000001000000640000000b00000001000000640000000900000001000000640000000f00000001000000640000000d00000001000000640000000e00000001000000640000001000000001000000640000001100000001000000640000001300000001000000640000001700000001000000640000001600000001000000640000002100000001000000640000005000000001000000640000001f0000000100000064000000200000000100000064000000" /f
reg.exe add "HKCU\Software\7-Zip\FM\Columns" /v "7-Zip.Rar5" /t REG_BINARY /d "01000000040000000100000004000000010000001e0200000700000001000000640000000800000001000000640000000c00000001000000640000000a00000001000000640000000b00000001000000640000000900000001000000640000003f00000001000000640000000f00000001000000640000000d00000001000000640000001000000001000000640000001100000001000000640000001300000001000000640000001700000001000000640000001600000001000000640000002f00000001000000640000003600000001000000640000005a00000001000000640000005f00000001000000640000005000000001000000640000001f00000001000000640000002000000001000000640000002e00000001000000640000003e0000000100000064000000" /f
reg.exe add "HKCU\Software\7-Zip\FM\Columns" /v "7-Zip.Iso" /t REG_BINARY /d "0100000004000000010000000400000001000000030200000700000001000000640000000800000001000000640000000c00000001000000640000003500000001000000640000003600000001000000640000001f0000000100000064000000200000000100000064000000" /f
reg.exe add "HKCU\Software\7-Zip\FM\Columns" /v "7-Zip.zip" /t REG_BINARY /d "0100000004000000010000000400000001000000a00000000700000001000000640000000800000001000000640000000c00000001000000640000000a00000001000000640000000b00000001000000640000000900000001000000640000000f00000001000000640000001c00000001000000640000001300000001000000640000001600000001000000640000002f00000001000000640000001700000001000000640000002100000001000000640000005000000001000000640000002400000001000000640000001f0000000100000064000000200000000100000064000000" /f
reg.exe add "HKCU\Software\7-Zip\Options" /v "CascadedMenu" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\7-Zip\Options" /v "MenuIcons" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\Options" /v "ContextMenu" /t REG_DWORD /d "807" /f
reg.exe add "HKCU\Software\7-Zip\Options" /v "WorkDirType" /t REG_DWORD /d "1" /f
reg.exe add "HKCU\Software\7-Zip\Options" /v "WorkDirPath" /t REG_SZ /d "E:\_temp" /f
reg.exe add "HKCU\Software\7-Zip\Options" /v "TempRemovableOnly" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\7-Zip\Options" /v "ElimDupExtract" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\7-Zip" /ve /t REG_SZ /d "{23170F69-40C1-278A-1000-000100020000}" /f
Reg.exe add "HKLM\SOFTWARE\Classes\CLSID\{23170F69-40C1-278A-1000-000100020000}" /ve /t REG_SZ /d "7-Zip Shell Extension" /f
Reg.exe add "HKLM\SOFTWARE\Classes\CLSID\{23170F69-40C1-278A-1000-000100020000}\InprocServer32" /ve /t REG_SZ /d "C:\pro\_files\7-Zip\7-zip.dll" /f
Reg.exe add "HKLM\SOFTWARE\Classes\CLSID\{23170F69-40C1-278A-1000-000100020000}\InprocServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f
Reg.exe add "HKLM\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\7-Zip" /ve /t REG_SZ /d "{23170F69-40C1-278A-1000-000100020000}" /f
Reg.exe add "HKLM\SOFTWARE\Classes\Directory\shellex\DragDropHandlers\7-Zip" /ve /t REG_SZ /d "{23170F69-40C1-278A-1000-000100020000}" /f
Reg.exe add "HKLM\SOFTWARE\Classes\Drive\shellex\DragDropHandlers\7-Zip" /ve /t REG_SZ /d "{23170F69-40C1-278A-1000-000100020000}" /f
Reg.exe add "HKLM\SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\7-Zip" /ve /t REG_SZ /d "{23170F69-40C1-278A-1000-000100020000}" /f
Reg.exe add "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{23170F69-40C1-278A-1000-000100020000}" /ve /t REG_SZ /d "7-Zip Shell Extension" /f
Reg.exe add "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{23170F69-40C1-278A-1000-000100020000}\InprocServer32" /ve /t REG_SZ /d "C:\pro\_files\7-Zip\7-zip32.dll" /f
Reg.exe add "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{23170F69-40C1-278A-1000-000100020000}\InprocServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" /v "{23170F69-40C1-278A-1000-000100020000}" /t REG_SZ /d "7-Zip Shell Extension" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" /v "{23170F69-40C1-278A-1000-000100020000}" /t REG_SZ /d "7-Zip Shell Extension" /f


rem Sysinternals utilities - license accepted
Reg.exe add "HKCU\SOFTWARE\Sysinternals\AccessEnum" /v "EulaAccepted" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Sysinternals\Autologon" /v "EulaAccepted" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Sysinternals\Autoruns" /v "EulaAccepted" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Sysinternals\Process Monitor" /v "EulaAccepted" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Sysinternals\PsExec" /v "EulaAccepted" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Sysinternals\PsService" /v "EulaAccepted" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Sysinternals\PsSuspend" /v "EulaAccepted" /t REG_DWORD /d "1" /f


if exist "C:\Program Files\Microsoft Visual Studio\2022\" (
	rem visual studio - disable telemetry 
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKU\%usersid%\Software\Microsoft\VisualStudio\Telemetry" /v TurnOffSwitch /t REG_DWORD /d 1 /f
	reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VSStandardCollectorService150
	if %errorlevel%==0 (
		sc.exe config VSStandardCollectorService150 start= disabled
		sc.exe stop VSStandardCollectorService150
	)
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Microsoft\VSCommon\14.0\SQM" /v OptIn /t REG_DWORD /d 0 /f
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Microsoft\VSCommon\15.0\SQM" /v OptIn /t REG_DWORD /d 0 /f
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\SQM" /v OptIn /t REG_DWORD /d 0 /f
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" /v DisableEmailInput /t REG_DWORD /d 1 /f
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" /v DisableFeedbackDialog /t REG_DWORD /d 1 /f
	"..\..\_tools\_apps\PowerRun\PowerRun.exe" reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" /v DisableScreenshotCapture /t REG_DWORD /d 1 /f
	
	rem visual studio - disable CPU hungry background update when IDE is closed
	schtasks /Change /tn "\Microsoft\VisualStudio\Updates\BackgroundDownload" /DISABLE
	
	rem visual studio - delete useless context menu option "Open with Visual Studio" in File Explorer
	reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\AnyCode" /f
	reg delete "HKEY_CLASSES_ROOT\Directory\shell\AnyCode" /f
)

rem ASUS Armory Crate - delete useless context menu option "Game Library" in File Explorer
if exist "C:\Program Files (x86)\ASUS\ArmouryDevice\" (
	Reg.exe delete "HKCR\Directory\Background\shell\GameLibrary" /f
)

REM ;exclude file types from Search Indexing to increase performance, if you using other apps for files search (e.g. Total Commander)
"..\..\_tools\_apps\PowerRun\PowerRun.exe" regedit.exe /S "%~dp0_registry-tweaks\Windows-Search-indexing--excluded-files-extensions.reg"

gpupdate /force

@echo off
@echo.
@echo.
@echo.
@echo.
@echo Done.
@echo.
if [%1]==[] pause

exit /b