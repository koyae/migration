#!/bin/sh

if [[ -f ~/.gitconfig1 ]]; then
	read -r -d '' def <<-'EOF'
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
	EOF
	vim ~/.gitconfig -c "$def" -c ":call Verytemporary()"
else
	echo "Gitconfig supplement at $target not found."
	kill -INT $$
fi
