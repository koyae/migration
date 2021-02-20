@echo off
REM from admin CMD:
set realsettingsdir=%CYGHOME%\.vs_code\
set fakesettingsdir=%APPDATA%\Code\User\

call :nukeandlink %realsettingsdir%\keybindings.json %fakesettingsdir%\keybindings.json
call :nukeandlink %realsettingsdir%\settings.json %fakesettingsdir%\settings.json

exit /b

REM expects: nukeandlink linksource linkdest
REM expects: linksource  --  path defining a concrete file to link to
REM expects: linkdest    --  path where link will be placed
:nukeandlink 
set linksource=%~1
set linkdest=%~2
IF NOT EXIST "%linksource%" (
	echo "%linksource% does not exist so unsafe to overwrite %linkdest%"
	echo "Aborting"
	exit /b
)
del %linkdest% 
mklink %linkdest% %linksource%
exit /b
