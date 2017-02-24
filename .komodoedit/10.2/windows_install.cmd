@echo off
rem You may need to use a command-prompt that has elevated privileges to execute
rem this script. Consider installing `elevate` for your system so you can just
rem elevate -c 'script.cmd'
setlocal enabledelayedexpansion

set scriptdir=%~dp0

call :makelinks "%scriptdir%tools\ktools" "tools\ktools" 1 
for /F "delims=" %%m in ('dir /B "%scriptdir%\schemes"\*.kkf') do (
	echo makelinks %scriptdir%schemes\%%~nxm "schemes" 0
	call :makelinks "%scriptdir%schemes\%%~nxm" "schemes" 0
)

exit /b
rem end main code

 
:makelinks
rem
rem expects CALL :makelinks source desttail isdir
rem source    --  either a folder or a directory
rem desttail  --  the sub-path within the Komodo settings-directory/directories 
rem               where the symbolic link should be placed
rem isdir     --  indicates whether source is a regular file or a directory.
rem               0 connotes regular file, 1 connotes directory

set source=%~f1
set desttail=%~2
set /a isdir=%~3
rem /a because number
  
set sourcename=%~nx1
set tooldir=%APPDATA%\..\Local\ActiveState\KomodoEdit

echo SOURCENAME:
echo.%sourcename%
echo SOURCE:
echo.%source%
echo DESTTAIL:
echo.%desttail%
echo ISDIR:
echo.%isdir%
  
rem The tooldir directory contains a set of subdirecties which correspond to
rem different versions of Komodo if there are multiple versions installed.
rem Since we don't know which version(s) the caller necessarily has installed,
rem we just link the macro-folder into all such version-subdirectories.
for /F "delims=" %%i in ('dir /B /AD "%tooldir%"') do (
rem The "delims=" causes us to only split by newline below.
	set version=%%~i
	set dest="!tooldir!\!version!\!desttail!"
	echo PREDEST:
	echo.!dest!
	if !isdir! EQU 0 (
		set "dest=!dest!\!sourcename!"
		echo REDEST:
		echo.!dest!
		mklink "!dest!" "!source!" 
	) else (
		mklink /D "!dest!" "!source!"
	)
	echo POSTDEST:
	echo.!dest!
	echo Tried linking: !source! to !dest!
	echo.
)
exit /b
