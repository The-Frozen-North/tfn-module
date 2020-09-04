@echo off

set DefaultSteamPath=C:\Program Files (x86)\Steam\steamapps\common\Neverwinter Nights\bin\win32\nwtoolset.exe
if exist "%DefaultSteamPath%" (
	echo DefaultSteamPath found: "%DefaultSteamPath%"
	START "" "%DefaultSteamPath%" -userdirectory "%cd%"
	exit
)

set DefaultGogPath=C:\Program Files (x86)\GOG Galaxy\Games\Neverwinter Nights Enhanced Edition\bin\win32\nwtoolset.exe
if exist "%DefaultGogPath%" (
	echo DefaultGogPath found: "%DefaultGogPath%"
	START "" "%DefaultGogPath%" -userdirectory "%cd%"
	exit
)

set DefaultBeamdogPath=C:\Users\%USERNAME%\Beamdog Library\00785\bin\win32\nwtoolset.exe
if exist "%DefaultBeamdogPath%" (
	echo DefaultBeamdogPath found: "%DefaultBeamdogPath%"
	START "" "%DefaultBeamdogPath%" -userdirectory "%cd%"
	exit
)

(for /f "usebackq tokens=1,2,*" %%a in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam" /v UninstallString`) do set SteamPath32=%%c)>nul 2>&1
(for /f "usebackq tokens=1,2,*" %%a in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam" /v UninstallString`) do set SteamPath64=%%c)>nul 2>&1
set SteamPath=%SteamPath64%%SteamPath32%
set SteamPath=%SteamPath:\uninstall.exe=%
set SteamPath=%SteamPath%\steamapps\common\Neverwinter Nights\bin\win32\nwtoolset.exe
if exist "%SteamPath%" (
	echo Steam Path found: "%SteamPath%"
	START "" "%SteamPath%" -userdirectory "%cd%"
	exit
)

(for /f "usebackq tokens=1,2,*" %%a in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\GOG.com\Games\1097893768" /v PATH`) do set GogPath=%%c)>nul 2>&1
set GogPath=%GogPath%\bin\win32\nwtoolset.exe

if exist "%GogPath%" (
	echo GoG path found: "%GogPath%"
	START "" "%GogPath%" -userdirectory "%cd%"
	exit
)
pause
