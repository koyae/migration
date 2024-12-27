#!/bin/bash

# .bash_profile - stuff that only makes sense for interactive shells

# Since the presence of a .profile or .bash_profile in the home-directory
# causes execution of .bashrc to be skipped by default, source it explicitly:
if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi

stty stop ''; stty start ''; stty -ixon; stty -ixoff
# ^ disable freeze and unfreeze commands to free ctrlS and ctrlQ

function should_start_agent {
	if [[ $(uname) = *cygwin*  ]] || [[ $(uname) = *CYGWIN* ]]; then
		return 0
	fi
	if [[ $(uname -a) = *Ubuntu* ]]; then
	# NOTE: in Ubunutu's basic gnome-terminal, interactivity can (and should
	# be) set via Edit (e) -> Profiles (r) -> Title and command (right) -> "Run
	# command as a login shell" ...A similar setting should be available in
	# Terminator 2.0 (also under Profile-settings), but is not available in the
	# packaged Terminator 0.98 which ships with Ubuntu 14, so its use is not
	# recommended.
		return 0
	fi
	return 1
}

if should_start_agent; then
	if [[ "$SSH_ASKPASS" = "" ]]; then
		1>&2 echo "SSH_ASKPASS is unset. SSH-agent will not be started."
	else
		echo "Interactive shell detected. SSH-agent starting."
		export DISPLAY=:0
		exec ssh-agent /bin/bash
	fi
fi

export PS1="\u [\t] \w> "
