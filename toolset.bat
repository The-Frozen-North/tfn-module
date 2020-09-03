if exist "C:\Program Files (x86)\Steam\steamapps\common\Neverwinter Nights\bin\win32\nwtoolset.exe" goto steam

:steam
START "" "C:\Program Files (x86)\Steam\steamapps\common\Neverwinter Nights\bin\win32\nwtoolset.exe" -userdirectory "%cd%"

:gog

:bdc

