#!/bin/bash

# .bash_profile - stuff that only makes sense for interactive shells 

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

