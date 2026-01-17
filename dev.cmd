@echo off
set "TRACE=1"
if "%TRACE%"=="1" @echo on
setlocal enabledelayedexpansion

rem =============================
rem Configuration
rem =============================
set "ROOT=%~dp0"
set "QT_PREFIX=C:\Qt\6.10.1\msvc2022_64"
set "QT6_DIR=%QT_PREFIX%\lib\cmake\Qt6"
set "QT_BIN=%QT_PREFIX%\bin"
set "VCVARS=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"

set "MODE=debug"
set "CLEAN=0"
set "DO_INSTALL=0"
set "DO_RUN=0"

rem =============================
rem Parse args
rem =============================
for %%A in (%*) do (
  if /I "%%A"=="install" set DO_INSTALL=1
  if /I "%%A"=="run" set DO_RUN=1
  if /I "%%A"=="clean" set CLEAN=1
  if /I "%%A"=="rel" set MODE=rel
)

if "%MODE%"=="rel" (
  set "BUILD=%ROOT%cmake-build-relwithdebinfo"
  set "CMAKE_TYPE=RelWithDebInfo"
) else (
  set "BUILD=%ROOT%cmake-build-debug"
  set "CMAKE_TYPE=Debug"
)

set "INSTALL=%BUILD%\install"
set "EXE=%INSTALL%\bin\MuseScore4.exe"

echo =====================================
echo MuseScore dev script
echo Mode: %CMAKE_TYPE%
echo Clean: %CLEAN%
echo Install: %DO_INSTALL%
echo Run: %DO_RUN%
echo BuildDir: %BUILD%
echo =====================================

rem =============================
rem Init MSVC
rem =============================
call "%VCVARS%" >nul || exit /b 1

rem =============================
rem Kill running exe (LNK1168 guard)
rem =============================
taskkill /F /IM MuseScore4.exe >nul 2>nul & rem ignore

rem =============================
rem Clean build dir if requested
rem =============================
if "%CLEAN%"=="1" (
  echo Cleaning build directory...
  rmdir /S /Q "%BUILD%" 2>nul
)

rem =============================
rem Configure if needed
rem =============================
echo Configuring CMake (if needed)...
set "CFG_RC=0"
if not exist "%BUILD%\CMakeCache.txt" (
  call :configure
  set "CFG_RC=%ERRORLEVEL%"
)
if not "%CFG_RC%"=="0" exit /b %CFG_RC%

rem =============================
rem Build (use a reasonable parallelism)
rem =============================
echo Building...
cmake --build "%BUILD%" -j 8 || exit /b 1

rem =============================
rem Install (only when requested)
rem =============================
if "%DO_INSTALL%"=="1" (
  echo Installing...
  cmake --build "%BUILD%" --target install || exit /b 1

  rem Deploy Qt runtime only when installing
  if exist "%QT_BIN%\windeployqt.exe" (
    "%QT_BIN%\windeployqt.exe" "%EXE%" >nul
  )
)

rem =============================
rem Run
rem =============================
if "%DO_RUN%"=="1" (
  if not exist "%EXE%" (
    echo ERROR: %EXE% not found. Run: dev.cmd rel install run
    exit /b 1
  )
  echo Starting MuseScore...
  start "" "%EXE%"
)

exit /b 0

:configure
pushd "%ROOT%"

cmake -S . -B "%BUILD%" -G Ninja ^
  -DCMAKE_BUILD_TYPE=%CMAKE_TYPE% ^
  -DQt6_DIR="%QT6_DIR%" ^
  -DCMAKE_PREFIX_PATH="%QT_PREFIX%" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL%" ^
  -DCMAKE_C_COMPILER_LAUNCHER=sccache ^
  -DCMAKE_CXX_COMPILER_LAUNCHER=sccache ^
  -DCMAKE_C_FLAGS_RELWITHDEBINFO="/Z7" ^
  -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="/Z7" ^
  -DMUSE_COMPILE_USE_UNITY=OFF

set "CMAKE_RC=%ERRORLEVEL%"
popd

echo Configure returned ERRORLEVEL=%CMAKE_RC%
exit /b %CMAKE_RC%