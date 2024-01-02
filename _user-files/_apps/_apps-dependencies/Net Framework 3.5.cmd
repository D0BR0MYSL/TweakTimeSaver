@echo off
cls
>NUL 2>&1 REG QUERY "HKU\S-1-5-19" ||(
	echo.
 	echo ATTENTION: You should run this file as an Administrator.
 	echo.
	pause >nul
	pause
	exit
)

@echo.
@echo.
@echo .Net Framework 3.5 install:
@echo.
pause

dism.exe /online /enable-feature /featurename:NetFx3 /all

@echo.
@echo.
@echo Done.
@echo.
pause >nul

exit /b