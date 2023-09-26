rem 

@echo off
echo Setting PATH for XILINX SDK

rem Modify the following line to point to where you have decompressed the SDK:
set mbsdk=d:/mbsdk

set path=%mbsdk%/gnuwin/bin;%mbsdk%/gnu/microblaze/nt/bin;%path%


color 0a

pushd 

cd application
cd Debug
make clean

popd.

pause


