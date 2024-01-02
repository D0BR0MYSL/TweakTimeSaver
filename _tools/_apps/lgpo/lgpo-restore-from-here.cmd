@echo off
cls
>NUL 2>&1 REG QUERY "HKU\S-1-5-19" ||(
	echo.
 	echo ВНИМАНИЕ: следует запустить этот файл от имени Администратора.
 	echo.
	pause >nul
	pause
	exit
)

@echo.
@echo После нажатия любой клавиши параметры Локальной Групповой Политики будут
@echo загружены из файлов с предварительными настройками.
@echo.
@echo Примечания: 
@echo 1) применение настроек приведёт к отключению функций Защитника Windows;
@echo.
@echo 2) отмена настроек, сделанных через Групповую Политику, будет
@echo    будет возможна только из оснастки "gpedit.msc", поэтому, для
@echo    упрощения их возврата (по желанию), сперва будет автоматически сделана
@echo    резервная копия текущих Групповых Политик.
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
@echo Создание резервной копии Локальной Групповой Политики...

::creating backup in _user-files folder
lgpo.exe /q /b "%~dp0\"

@echo.
@echo.
@echo Применение готовых настроек Локальной Групповой Политики:
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
@echo Выполнение завершено.
@echo Настройки вступят в силу после перезагрузки.
@echo.
@echo.
pause
exit /b