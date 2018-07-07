inoremap <F4> $
nnoremap <expr> <F4> ToInsertBeforeCurrentChar('$')
inoremap <F6> $this->
inoremap <expr> <A-a> ArrayHelp()

" Insert the comment leader when pressing <Enter> from Insert mode:
setlocal formatoptions+=r
" This is most helpful for PHP's long '/*' doc comments.

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

