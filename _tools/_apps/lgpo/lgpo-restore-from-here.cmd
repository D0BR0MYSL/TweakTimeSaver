@echo off
cls
>NUL 2>&1 REG QUERY "HKU\S-1-5-19" ||(
	echo.
 	echo ��������: ᫥��� �������� ��� 䠩� �� ����� �����������.
 	echo.
	pause >nul
	pause
	exit
)

@echo.
@echo ��᫥ ������ �� ������ ��ࠬ���� �����쭮� ��㯯���� ����⨪� ����
@echo ����㦥�� �� 䠩��� � �।���⥫�묨 ����ன����.
@echo.
@echo �ਬ�砭��: 
@echo 1) �ਬ������ ����஥� �ਢ���� � �⪫�祭�� �㭪権 ���⭨�� Windows;
@echo.
@echo 2) �⬥�� ����஥�, ᤥ������ �१ ��㯯���� ����⨪�, �㤥�
@echo    �㤥� �������� ⮫쪮 �� �᭠�⪨ "gpedit.msc", ���⮬�, ���
@echo    ��饭�� �� ������ (�� �������), ᯥࢠ �㤥� ��⮬���᪨ ᤥ����
@echo    १�ࢭ�� ����� ⥪��� ��㯯���� ����⨪.
@echo.
@echo.
pause >nul
pause 

for /f "delims=" %%i in ('wmic useraccount get name^,sid ^| findstr /vi "SID"') do @for /F %%a in ("%%i") do if exist "C:\users\%%a" set buffer=%%i
set username=%buffer:~0,18%
::remove spaces
set username=%username: =%

@echo.
@echo.
@echo �������� १�ࢭ�� ����� �����쭮� ��㯯���� ����⨪�...

::creating backup in _user-files folder
lgpo.exe /q /b "%~dp0\"

@echo.
@echo.
@echo �ਬ������ ��⮢�� ����஥� �����쭮� ��㯯���� ����⨪�:
@echo.
@echo %~dp0
@echo     tweaks.pol

::restoring local group policy predefined profile 
lgpo.exe /q /u:%username% tweaks.pol
lgpo.exe /q /ua tweaks.pol
lgpo.exe /q /u tweaks.pol

@echo     security.pol
::restoring local group policy predefined profile
lgpo.exe /q /u:%username% security.pol
lgpo.exe /q /ua security.pol
lgpo.exe /q /u security.pol

@echo.
gpupdate /force

@echo.
@echo �믮������ �����襭�.
@echo ����ன�� ������ � ᨫ� ��᫥ ��१���㧪�.
@echo.
@echo.
pause
exit /b