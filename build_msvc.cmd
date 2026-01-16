@echo off
echo Initializing MSVC environment...
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
echo.

echo INCLUDE is:
echo %INCLUDE%
echo.

echo Building MuseScore...
cmake --build "%~dp0cmake-build-debug" -j %NUMBER_OF_PROCESSORS%
