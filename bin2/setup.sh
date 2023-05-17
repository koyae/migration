#!/bin/sh

oldcwd=`command pwd`
cd ~
git config user.email "koyae@users.noreply.github.com"
nothing_to_overwrite=0
include_path="$(git config --global include.path)"
if [ $? -eq 1 ]; then
	nothing_to_overwrite=1
fi
printf '%s' "$include_path" | grep -qe '\.gitconfig1'
if [ $? -ne 0 ]; then
	if [ $nothing_to_overwrite -ne 1 ]; then
		echo "Previous value(s) of git include.path present:" 1>&2
		git config --global --get-all include.path | sed 's/^/\t/' 1>&2
		printf '%s%s\n' "... Nondestructively added include path to"\
		' $GIT_CONFIG_GLOBAL, ~/.gitconfig, or $XDG_CONFIG_PATH/git/config'\
		"(whichever was found first)"
	fi
	git config --global --add include.path "$(pwd -P)/.gitconfig1"
else
	echo "Git include.path appears to be correct: $include_path" 1>&2
	echo "(Doing nothing.)" 1>&2
fi
cd "$oldcwd"
