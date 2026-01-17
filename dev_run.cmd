@echo off
setlocal

rem --- Project paths ---
set "ROOT=%~dp0"
set "BUILD=%ROOT%cmake-build-debug"
set "INSTALL=%BUILD%\install"
set "EXE=%INSTALL%\bin\MuseScore4.exe"

rem --- Tooling paths ---
set "VCVARS=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
set "QT_BIN=C:\Qt\6.10.1\msvc2022_64\bin"
set "QT6_DIR=C:\Qt\6.10.1\msvc2022_64\lib\cmake\Qt6"
set "QT_PREFIX=C:\Qt\6.10.1\msvc2022_64"

echo [1/6] Init MSVC environment...
call "%VCVARS%" >nul
if errorlevel 1 (
  echo ERROR: vcvars64.bat failed: "%VCVARS%"
  exit /b 1
)

echo [2/6] Close running MuseScore (avoid LNK1168)...
taskkill /F /IM MuseScore4.exe >nul 2>nul

echo [3/6] Configure (only if first time)...
if not exist "%BUILD%\CMakeCache.txt" (
  cmake -S "%ROOT%" -B "%BUILD%" -G Ninja ^
    -DQt6_DIR="%QT6_DIR%" ^
    -DCMAKE_PREFIX_PATH="%QT_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%INSTALL%"
  if errorlevel 1 exit /b 1
)

echo [4/6] Build...
cmake --build "%BUILD%" -j %NUMBER_OF_PROCESSORS%
if errorlevel 1 exit /b 1

echo [5/6] Install...
cmake --build "%BUILD%" --target install
if errorlevel 1 exit /b 1

echo [6/6] Deploy Qt runtime (best-effort)...
if exist "%QT_BIN%\windeployqt.exe" (
  "%QT_BIN%\windeployqt.exe" "%EXE%" >nul
)

if not exist "%EXE%" (
  echo ERROR: Exe not found: "%EXE%"
  exit /b 1
)

echo Starting: "%EXE%"
start "" "%EXE%"
exit /b 0