@echo off

lgpo.exe /r tweaks_apply.txt /w tweaks_apply.pol
lgpo.exe /r security_apply.txt /w security_apply.pol
lgpo.exe /r tweaks_reset.txt /w tweaks_reset.pol
lgpo.exe /r security_reset.txt /w security_reset.pol

exit /b