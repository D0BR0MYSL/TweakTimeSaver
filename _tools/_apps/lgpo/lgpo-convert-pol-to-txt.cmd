@echo off

lgpo.exe /parse /m tweaks_apply.pol >>tweaks_apply.txt
rem lgpo.exe /parse /u:%username% tweaks_apply.pol >>tweaks_apply-%username%.txt
lgpo.exe /parse /m security_apply.pol >>security_apply.txt
rem lgpo.exe /parse /u:%username% security_apply.pol >>security_apply-%username%.txt
lgpo.exe /parse /m tweaks_reset.pol >>tweaks_reset.txt
rem lgpo.exe /parse /u:%username% tweaks_reset.pol >>tweaks_reset-%username%.txt
lgpo.exe /parse /m security_reset.pol >>security_reset.txt
rem lgpo.exe /parse /u:%username% security_reset.pol >>security_reset-%username%.txt

exit /b