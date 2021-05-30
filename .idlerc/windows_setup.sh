#!/bin/sh

cd "$USERPROFILE"
path_to_remove="$(pwd)/.idlerc/config-highlight.cfg"
cd - >/dev/null

if [ -f "$path_to_remove" ]; then
	printf "Remove %s and replace with a symbolic link? " "$path_to_remove"
	read -n 1
	echo ""
	if [ "$REPLY" = "y" ]; then
		rm "$path_to_remove"
		win_idle_highlight_conf="$(cmd /c echo %USERPROFILE%\\.idlerc\\config-highlight.cfg)"
		cd "$(dirname $0)"
		win_pwd="$(cmd /c echo %CD%)"
		cd - >/dev/null
		powershell "Start-Process -Verb RunAs cmd '/c mklink $win_idle_highlight_conf $win_pwd\\config-highlight.cfg'"
	else
		1>&2 echo "Aborted."
		exit 1
	fi
else
	1>&2 echo "Nothing to replace or folder link between ~/.idlerc and $USERPROFILE/.idlerc has already been created"
	exit 1
fi

