if exist "C:\Program Files (x86)\Steam\steamapps\common\Neverwinter Nights\bin\win32\nwtoolset.exe" goto steam

if exist "C:\Program Files (x86)\GOG Galaxy\Games\Neverwinter Nights Enhanced Edition\bin\win32\nwtoolset.exe" goto gog

:steam
START "" "C:\Program Files (x86)\Steam\steamapps\common\Neverwinter Nights\bin\win32\nwtoolset.exe" -userdirectory "%cd%"

:gog
START "" "C:\Program Files (x86)\GOG Galaxy\Games\Neverwinter Nights Enhanced Edition\bin\win32\nwtoolset.exe" -userdirectory "%cd%"


:bdc

