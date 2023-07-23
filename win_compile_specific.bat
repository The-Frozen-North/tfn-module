@echo off
echo This simply tries to compile one nss source file. Useful when nasher can't tell you why things aren't compiling.

:start
set "ncs="
set /p "ncs=Enter script name (or blank to exit): "
if "%ncs%"=="" goto end

mkdir "%CD%/_tmp"
"%CD%/tools/win/nwnsc/nwnsc.exe" -b "%CD%/_tmp" -i "%CD%/src/nss;%CD%/nwn-base-scripts" "%CD%/src/nss/%ncs%.nss"
del "%CD%/_tmp/%ncs%.ncs"
rmdir "%CD%/_tmp"

goto start

:end