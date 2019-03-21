set textwidth=80
" 2: Don't automatically wrap SQL but do wrap comments and add the
" comment-leader to the new line if necessary to extend the comment:
set formatoptions-=t
set formatoptions+=c
" Allow Python-style parameter-docs to wrap as expected:
set formatoptions+=2

" Jump to start or end of function-definitions:
vnoremap <buffer> gz :<C-u>call search('\%>'.line("'>").'l\V$$')<Return>V`<o
" ^ Since we hop to the end of the line after starting visual-line mode, we
" don't need fancyness for this, since we'll always be past the '$$'
vnoremap <buffer> gZ :<C-u>call search('\V$$','b',line('.'))<Return>m``>V``?\V$$<Return>
" ^ Here, we hop to the match given by search (avoids errors on fail, though
" drops out of visual mode), mark our spot, jump back to previous selection-end
" reengage visual mode, then search. This avoids having to repeat gZ if we're
" already on the same line as the '$$'
nnoremap <buffer> gz /\V$$<Return>
nnoremap <buffer> gZ ?\V$$<Return>
" g-then-s goes to next plpgsql section:
nmap <buffer> gs /^\(DECLARE\\|BEGIN\\|END;\)<Return>
" g-key-then-shiftS goes to previous plpgsql section:
nmap <buffer> gS ?^\(DECLARE\\|BEGIN\\|END;\)<Return>
" altF flips current keyword to alternative:
nmap <buffer> <A-f> W:<C-u>let @p=PgFlip(GetSelectionText())<Return>gvx"pP
vmap <buffer> <A-f> :<C-u>let @p=PgFlip(GetSelectionText())<Return>gvx"pP

" replace '00' with '--', since it's a common typo for me:
ia <buffer> 00 --

" Given a string (usually a keyword) return the common replacement for that
" string
function! PgFlip(str)
	let dic = {
		\ 'ENABLE': 'DISABLE',
		\ 'DISABLE': 'ENABLE',
		\ 'SELECT': 'PERFORM',
		\ 'PERFORM': 'SELECT',
		\ 'MIN': 'MAX',
		\ 'MAX': 'MIN'
	\ }
	return get(dic, a:str, a:str)
endfunction

" Highlight the COMMENT, DO, or CREATE statement in which the cursor currently
" resides, and then press F5 to pipe the text to the outside (see .vimrc for
" details on what that binding does from visual mode):
command! Re normal mwgZ:echo (search('\%'.line('.').'l^[CD]','b'))? 0 : search('^[CD]','b') <Return>^mugzgzV`u<F5>`w
" ^ This covers CREATE statements, COMMENT statements, and DO statements
Alias re Re

" Copy the filename of the current buffer to register p, expressing the path
" as relative, under the assumption that the current working directory is in a
" subdirectory of the same parent-dir in which the file's immediate
" parent-folder resides:
command! Thisfile let @p="'../" . expand('%:p:h:t') . "/" . expand('%:t') . "'"
Alias thisfile Thisfile

command! Scratch tabe scratch.postgre.sql
Alias scratch Scratch

" -- Ultisnips helpers:

function! PlpgBody()
	return "DECLARE\nBEGIN\nEND;"
endfunction

