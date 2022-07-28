@echo off
echo This recompiles all .ncs (compiled scripts) in the /development folder, from those in /src/nss.
echo Compiled scripts in the development folder are used in preference to the module ones, and reflect changes in real time!
echo This can be used to quickly change a few scripts while the server is running, and save the time taken to restart the server each time.
echo Simply copy the .ncs files from /modules/TFN to recompile into the development folder before running this. The .nss files are not required.
echo Don't forget to remove the .ncs files from the development folder when done!

for %%f in ("%CD%/development/*.ncs") do (
	"%CD%/tools/win/nwnsc/nwnsc.exe" -b "%CD%/development" -i "%CD%/nwn-base-scripts;%CD%/src/nss" "%CD%/src/nss/%%~nf.nss"
)
@echo on

PAUSE