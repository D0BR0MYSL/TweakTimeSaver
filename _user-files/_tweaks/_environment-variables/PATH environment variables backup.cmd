@echo off
echo.
@echo Creating backup of Windows Environment Variables...

set datetime=(%DATE%)_%TIME%
set datetime=%datetime:/=0%
set datetime=%datetime::=0%
set datetime=%datetime:,=0%

reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "tmp_reg01.reg" /y >nul
reg export "HKCU\Environment" "tmp_reg02.reg" /y >nul
more "tmp_reg01.reg" > "tmp_reg1.reg"
more +1 "tmp_reg02.reg" > "tmp_reg2.reg"
copy "tmp_reg1.reg"+"tmp_reg2.reg" "PATH environment variable backup %datetime%.reg" /y >nul
del /f /q tmp_reg*.reg

echo.
echo Done.
@echo.
@echo Created a registry file :
@echo PATH environment variable backup %datetime%.reg
@echo.
pause