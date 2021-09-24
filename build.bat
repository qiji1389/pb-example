@echo off
setlocal enableextensions
setlocal EnableDelayedExpansion

set ARG_ACTION=%1
set ARG_PLAT=%2
set ARG_ARCH=%3
set ARG_CONF=%4

set CMAKE_EXE="C:\Program Files\CMake\bin\cmake.exe"
if not exist %CMAKE_EXE% set CMAKE_EXE=cmake

set GENERATOR="D:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
if not exist %GENERATOR% set GENERATOR="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
if not exist %GENERATOR% (
	echo Failed to locate MSBuild.exe of VS2017
	exit /b
)

cd %~dp0

if not defined ARG_ACTION set ARG_ACTION=build
if not defined ARG_PLAT set ARG_PLAT=win
if not defined ARG_ARCH set ARG_ARCH=x64
if not defined ARG_CONF set ARG_CONF=release

if %ARG_ACTION%==help goto HELP

if %ARG_ACTION%==allclean goto ALLCLEAN

if %ARG_ACTION%==create set ACTION=%ARG_ACTION%
if %ARG_ACTION%==build set ACTION=%ARG_ACTION%
if %ARG_ACTION%==clean set ACTION=%ARG_ACTION%

if %ARG_PLAT%==windows set ARG_PLAT=win
if %ARG_PLAT%==win (
	set PLAT=win
	set ARCH=x64
)

if %ARG_CONF%==debug set CONF=Debug
if %ARG_CONF%==release set CONF=RelWithDebInfo

if not defined ACTION goto HELP
if not defined PLAT goto HELP
if not defined ARCH goto HELP
if not defined CONF goto HELP

cd %~dp0

set PLAT_ARCH_CONF=%PLAT%\%ARCH%\%CONF%

set CURDIR=%~dp0
set CMAKEDIR=%~dp0..\cmake
set GENDIR=%~dp0build\%PLAT_ARCH_CONF%
set INSDIR=%~dp0..\lib\%PLAT_ARCH_CONF%

mkdir %GENDIR%
cd %GENDIR%

set BUILD_TYPE=%CONF%
set CMAKE_PARAM=-DCMAKE_INSTALL_PREFIX="%INSDIR%" -DCMAKE_CONFIGURATION_TYPES="%CONF%" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -G "Visual Studio 15 2017 Win64"

%CMAKE_EXE% %CMAKE_PARAM% %CURDIR%

if %ACTION%==build (
	cd %GENDIR%
	
	%GENERATOR% ALL_BUILD.vcxproj /p:Configuration=%CONF% /t:build
	if !ERRORLEVEL! NEQ 0 exit /b 1
)

cd %~dp0
exit /b 0

:HELP
echo USAGE: [create/build/clean/install/allclean] [win/all] [x64/all] [release/debug]
exit /b 1

:ALLCLEAN
echo on
rmdir /Q /S %~dp0build
exit /b 0

:CLEAN
echo on
rmdir /Q /S %GENDIR%
exit /b 0