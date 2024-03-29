#!/bin/bash
#calledvia=$_ # must be first line to work
#if [[ $calledvia != $0 ]]
# if .bashrc is being sourced from elsewhere
#fi

#### Function-definitions: ####

. "$HOME/define_funcs"

####: Function-definitions ####


#### Aliases and shell-tweaks: ####

# Global definitions:
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Shell tweaks:
alias mv='mv -i'
alias cp='cp -i'
alias cd='c_d'
alias ls='ls --color'
alias ll='ls -l --color'
alias lld='ls -ld'
alias du='duc'
alias df='df -h'
alias reup='echo Reloading .bashrc && . "$HOME/.bashrc" || . ~/.bashrc'
alias pwdp='pwd -P'
alias ssh='ssh -a' # use local ssh-agent if available, but do not allow challenges to be forwarded from remote servers
alias ssh-add='ssh-add -c' # require confirmation if agent-forwarding is about to occur (see README about requirements)
alias zip='zip -r' # zip recursively by default
alias grepc='grep --color=always'
alias diff="diff -r --brief"
alias :q=exit
alias in='task add +in' # taskwarrior inbox
shopt -s extglob # enable shell-extensions such as negation-based matching
# prevent spaces from automatically appearing by default after pressing tab-key
# for completion, since this is obnoxious when typing long paths:
complete -D -o default -o nospace
git config --global push.default upstream
git config --global color.ui auto # some systems oddly disable this

bind '"[1;5D":"b"' 2>/dev/null # ctrlLeft moves cursor one word back
bind '"[1;5C":"f"' 2>/dev/null # ctrlRight moves cursor one word forward
bind '"":""' 2>/dev/null # ctrlBackspace deletes previous word
bind Space:magic-space # allow backrefs like `!<command>` and `!!` to expand on hitting space

# [ additional control-signal stuff located in .bash_profile ]

# weird stuff:
alias l='ls'
alias down='cd'
alias cdP='cd "`pwd -P`"'
alias gith='cd "`git rev-parse --show-toplevel`"'
alias lastat='cd "$(cat "$HOME/lastat")"'
alias lastam='pwd > "$HOME/lastat"'
alias ssh-remove='ssh-add -d'
alias psql='psql $( [ -d /d/Job/chapow/back ] && echo -v home=/d/Job/chapow/back || echo -v home=/tmp)'
alias k1="kill %1"

# reset git working tree location, if it's borked:
read -r -d "" gitrwt <<-'EOF'
	vim .git/config -c 'call search("worktree = ","e")' -c 'normal! ld$a'"`pwd`" -c 'wq'
EOF
alias gitrwt="$gitrwt"
unset gitrwt

alias readreq='openssl req -noout -text -in'
alias reqread='openssl req -noout -text -in'

alias readcert='openssl x509 -noout -text -in'
alias certread='openssl x509 -noout -text -in'

alias pyaml="python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'"
# ^ Prettify YAML by converting it into JSON. Use by piping in a file with '<' operator.

# General envs:
if [[ -f $HOME/export_envs ]]; then
	. "$HOME/export_envs"
else
	echo '$HOME not set.'
	if [[ -f ~/export_envs ]]; then
		. ~/export_envs
	fi
fi
# ^ exports variables which should always be exported

# Machine-specific aliases and envs:
if [[ -f $HOME/export_local ]]; then
	. "$HOME/export_local"
else
	if [[ -f ~/export_local ]]; then
		. ~/export_local
	fi
fi
# ^ settings for local machine which may not work on other machines
# ^.. such as configs for uncommon programs or aliases which depend on
# ^.. or describe local file-structure
# ^ May export additional functions.


####: Aliases and shell-tweaks ####

# If not running interactively, don't do anything
# [[ "$-" != *i* ]] && exit

# Shell Options
#
# See man bash for more options...
#
# Don't wait for job termination notification
# set -o notify
#
# Don't use ^D to exit
# set -o ignoreeof
#
# Use case-insensitive filename globbing
# shopt -s nocaseglob
#
# Make bash append rather than overwrite the history on disk
# shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell

# Completion options
#
# These completion tuning parameters change the default behavior of bash_completion:
#
# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
#
# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1
#
# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
# [[ -f /etc/bash_completion ]] && . /etc/bash_completion

# History Options
#
# Don't put duplicate lines in the history.
# export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# Aliases
#
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
#
# Misc :)
# alias less='less -r'                          # raw control characters
# alias whence='type -a'                        # where, of a sort
# alias grep='grep --color'                     # show differences in colour
# alias egrep='egrep --color=auto'              # show differences in colour
# alias fgrep='fgrep --color=auto'              # show differences in colour
#
# Some shortcuts for different directory listings
# alias ls='ls -hF --color=tty'                 # classify files in colour
# alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
# alias ll='ls -l'                              # long list
# alias la='ls -A'                              # all but . and ..
# alias l='ls -CF'                              #

# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping,
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
# cd_func ()
# {
#   local x2 the_new_dir adir index
#   local -i cnt
#
#   if [[ $1 ==  "--" ]]; then
#     dirs -v
#     return 0
#   fi
#
#   the_new_dir=$1
#   [[ -z $1 ]] && the_new_dir=$HOME
#
#   if [[ ${the_new_dir:0:1} == '-' ]]; then
#     #
#     # Extract dir N from dirs
#     index=${the_new_dir:1}
#     [[ -z $index ]] && index=1
#     adir=$(dirs +$index)
#     [[ -z $adir ]] && return 1
#     the_new_dir=$adir
#   fi
#
#   #
#   # '~' has to be substituted by ${HOME}
#   [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"
#
#   #
#   # Now change to the new dir and add to the top of the stack
#   pushd "${the_new_dir}" > /dev/null
#   [[ $? -ne 0 ]] && return 1
#   the_new_dir=$(pwd)
#
#   #
#   # Trim down everything beyond 11th entry
#   popd -n +11 2>/dev/null 1>/dev/null
#
#   #
#   # Remove any other occurence of this dir, skipping the top of the stack
#   for ((cnt=1; cnt <= 10; cnt++)); do
#     x2=$(dirs +${cnt} 2>/dev/null)
#     [[ $? -ne 0 ]] && return 0
#     [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
#     if [[ "${x2}" == "${the_new_dir}" ]]; then
#       popd -n +$cnt 2>/dev/null 1>/dev/null
#       cnt=cnt-1
#     fi
#   done
#
#   return 0
# }
#
# alias cd=cd_func
