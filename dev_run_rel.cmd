@echo off
setlocal

set "ROOT=%~dp0"
set "BUILD=%ROOT%cmake-build-relwithdebinfo"
set "INSTALL=%BUILD%\install"
set "EXE=%INSTALL%\bin\MuseScore4.exe"

set "VCVARS=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
set "QT_BIN=C:\Qt\6.10.1\msvc2022_64\bin"
set "QT6_DIR=C:\Qt\6.10.1\msvc2022_64\lib\cmake\Qt6"
set "QT_PREFIX=C:\Qt\6.10.1\msvc2022_64"

call "%VCVARS%" >nul || exit /b 1
taskkill /F /IM MuseScore4.exe >nul 2>nul

if not exist "%BUILD%\CMakeCache.txt" (
  cmake -S "%ROOT%" -B "%BUILD%" -G Ninja ^
    -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
    -DQt6_DIR="%QT6_DIR%" ^
    -DCMAKE_PREFIX_PATH="%QT_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%INSTALL%" ^
    -DMUSE_COMPILE_USE_UNITY=ON
  if errorlevel 1 exit /b 1
)

cmake --build "%BUILD%" -j %NUMBER_OF_PROCESSORS% || exit /b 1
cmake --build "%BUILD%" --target install || exit /b 1

if exist "%QT_BIN%\windeployqt.exe" (
  "%QT_BIN%\windeployqt.exe" "%EXE%" >nul
)

start "" "%EXE%"
