
" F3-key adds an array-association arrow, with spaces on either side of it:
inoremap <buffer> <F3> => <C-o>:s/\([^ ]\)=>/\1 =>/e<Return><End>
" F4-key adds a dollar-sign:
inoremap <buffer> <F4> $
nnoremap <buffer> <expr> <F4> ToInsertBeforeCurrentChar('$')
" F6-key adds '$this->':
inoremap <buffer> <F6> $this->
" altA adds either "array()" or "['']", depending on context:
inoremap <buffer> <expr> <A-a> ArrayHelp()

" Insert the comment leader when pressing <Enter> from Insert mode:
setlocal formatoptions+=r
" This is most helpful for PHP's long '/*' doc comments.

" This string is taken from ~/.vim/indent/php.vim. For whatever reason, I find
" that the indent-settings themselves don't work right; possibly due to a
" settings or module conflict, though the commentstring seems to be right. My
" solution for now is just to set this here and not do `filetype indent on`
setlocal comments=s1:/*,mb:*,ex:*/,://,:#

function! UnmapI()
	iunmap <Tab>
endfunction

function! ArrayHelp()
	let c = GetCharFromCursor(-1)
	if col('.') == 1 || match(c,'\v[\t (]') == 0
		return "array()\<Left>"
	else
		let l:hack = "\<C-o>" . ':inoremap <Tab> <Right><Right><C-o>:call UnmapI()<Return>' . "\<Return>"
		" ^ Note: if <Tab> is ever mapped over to something in Insert mode,
		" this will need to restore the mapping, rather than just unsetting
		" it.
		return "['']\<Left>\<Left>" . l:hack
	endif
endfunction
