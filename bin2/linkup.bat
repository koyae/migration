@echo off
rem You can use this script to create the linkages you need if you
rem .. did `git clone` into home/migration, rather than the
rem .. `git init` route directly in the home folder.

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

for %%A in (%*) do (
    if "%%A"=="/help" goto show_help
    if "%%A"=="/h" goto show_help
    if "%%A"=="-help" goto show_help
    if "%%A"=="--help" goto show_help
    if "%%A"=="-h" goto show_help
)

set homedir=%~1
set migdir=%~2
if not defined homedir (set homedir=.)
if not defined migdir (set migdir=%homedir%\migration)

mklink /D "%homedir%"\bin2 "%migdir%"\bin2
mklink /D "%homedir%"\.vim "%migdir%"\.vim
mklink "%homedir%"\.bashrc "%migdir%"\.bashrc
mklink "%homedir%"\define_funcs "%migdir%"\define_funcs
mklink "%homedir%"\export_envs "%migdir%"\export_envs
mklink "%homedir%"\.vimrc "%migdir%"\.vimrc

endlocal
exit /b


:show_help
set "tab=	"
echo.
echo Call syntax: %~0 [home-directory[ migration-directory]]
echo.
echo %tab% home-directory -- directory in which new links are placed
echo.
echo %tab% migration-directory -- directory containing actual files 
echo. 
echo All parameters optional. Home-directory is assumed to be CWD if not given.
echo migration folder is assumed to be immediately nested within home-directory 
echo if omitted.
exit /b
