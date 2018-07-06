inoremap <F4> $
nnoremap <expr> <F4> ToInsertBeforeCurrentChar('$')
inoremap <F6> $this->
inoremap <expr> <A-a> ArrayHelp()

" This string is taken from ~/.vim/indent/php.vim. For whatever reason, I find
" that the indent-settings themselves don't work right; possibly due to a
" settings or module conflict, though the commentstring seems to be right. My
" solution for now is just to set this here and not do `filetype indent on`
setlocal comments=s1:/*,mb:*,ex:*/,://,:#

function! ArrayHelp()
	let c = GetCharFromCursor(-1)
	if col('.') == 1 || match(c,'\v[\t ]') == 0
		return "array()\<Left>"
	else
		return "['']\<Left>\<Left>"
	endif
endfunction

