#!/bin/bash

# .bash_profile - stuff that only makes sense for interactive shells 

# Since the presence of a .profile or .bash_profile in the home-directory
# causes execution of .bashrc to be skipped by default, source it explicitly:
if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi

stty stop ''; stty start ''; stty -ixon; stty -ixoff
# ^ disable freeze and unfreeze commands to free ctrlS and ctrlQ

if [[ $(uname) = *cygwin*  ]] || [[ $(uname) = *CYGWIN* ]]; then
	if [[ "$SSH_ASKPASS" = "" ]]; then
		1>&2 echo "SSH_ASKPASS is unset. SSH-agent will not be started." 
	else
		echo "Interactive shell detected. SSH-agent starting."
		export DISPLAY=:0
		exec ssh-agent /bin/bash
	fi
fi

