#!/bin/sh

oldcwd=`command pwd`
cd ~
git config user.email "koyae@users.noreply.github.com"
cd "$oldcwd"

if [ -f ~/.gitconfig1 ]; then
	f="$(mktemp)"
	read -r -d '' stuff <<-'EOF'
		:function! Verytemporary()
			let gohere = search('^\[include\]')
			if gohere==0
			" If nothing found:
				" Go to top:
				normal! gg
				" Create [include] section and bump whatever was on first line:
				execute "normal! i[include]\<Return>\<Esc>"
			endif
			let gohere = search('path \?= \? .gitconfig1')
			if gohere==0
				" Jump to appropriate line:
				execute gohere
				" Write a line below that does import:
				normal! opath = .gitconfig1
				" Do indent:
				normal! V>
				" Save changes:
				write
				" Exit vim:
				quit
			endif
		endfunction
		:call Verytemporary()
	EOF
	printf '%s' "$stuff"
	vim ~/.gitconfig -c "so $f"
	rm -f "$f"
else
	echo "Gitconfig supplement at $target not found."
	kill -INT $$
fi
