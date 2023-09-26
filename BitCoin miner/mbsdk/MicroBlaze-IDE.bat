@echo off

color 0a

echo Setting PATH for XILINX SDK

rem echo %~dp0
rem set mbsdk=C:/Windows/Temp/mbdsk
set path=%~dp0gnuwin\bin;%~dp0gnu\microblaze\nt\bin;%path%

echo Launching programmer's notepad
echo ------------------
echo Open the files to edit and use 
echo     Tools/MicroBlaze Make Clean 
echo and 
echo     Tools/MicroBlaze Make All 
echo to clean and make the project

pn\pn.exe

rem pause


