#!/bin/sh

if [[ -f ~/.gitconfig1 ]]; then
	read -r -d '' def <<-'EOF'
		:function Verytemporary()
			let gohere = search('^\[include\]')
			if gohere==0
				" Go to top:
				normal! gg
				" Create [include] section:
				normal! i[include]
			endif

			let gohere = search('path \?= \? .gitconfig1') 
			if gohere==0 
				" Insert a newline:
				normal! o
				" Write line that does import:
				normal! ipath = .gitconfig1
				" Do indent:
				normal! V>
				write
			endif
		endfunction
	EOF
	vim ~/.gitconfig -c "$def"
else
	echo "Gitconfig supplement at $target not found."
	kill -INT $$
fi
