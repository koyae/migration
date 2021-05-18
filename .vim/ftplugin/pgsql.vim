set textwidth=80
" 2: Don't automatically wrap SQL but do wrap comments and add the
" comment-leader to the new line if necessary to extend the comment:
set formatoptions-=t
set formatoptions+=c
" Allow Python-style parameter-docs to wrap as expected via the 'n' fo-flag
" (since '2' interferes with it):
set formatoptions-=2

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

noremap <buffer> gk /\(^\s*\)\@<=\(INSERT\\|SELECT [^1]\\|DELETE\\|PERFORM\\|WITH\)<Return>
noremap <buffer> gK ?\(^\s*\)\@<=\(INSERT\\|SELECT [^1]\\|DELETE\\|PERFORM\\|WITH\)<Return>

" backslash-then-d-then-f,
" backslash-then-d-then-f-then-f documents function under cursor:
vmap <buffer> <leader>df :<C-u>call AppendToFile('\df ' . GetSelectionText())<Return>
nmap <buffer> <leader>df viw\dff
vmap <buffer> <leader>dff :<C-u>call AppendToFile('\df ' . GetSelectionText())<Return>
nmap <buffer> <leader>dff viw\dff

" backslash-then-plus-then-d-then-f documents function under cursor with extra
" details:
vmap <buffer> <leader>df+ :<C-u>call AppendToFile('\df+ ' . GetSelectionText())<Return>
nmap <buffer> <leader>df+ viw\df+

" backslash-then-d,
" backslash-then-d-then-r documents relation under cursor:
vmap <buffer> <leader>d :<C-u>call AppendToFile('\d ' . GetSelectionText())<Return>
nmap <buffer> <leader>d viw\dr
vmap <buffer> <leader>dr :<C-u>call AppendToFile('\d ' . GetSelectionText())<Return>
nmap <buffer> <leader>dr viw\dr

" backslash-then-d-then-plus documents relation under cursor:
vmap <buffer> <leader>d+ :<C-u>call AppendToFile('\d+ ' . GetSelectionText())<Return>
nmap <buffer> <leader>d+ viw\d+

" backslash-then-F1 adds 'SELECT' onto current selection and then sends to
" fifo:
vmap <buffer> <leader><F1> :<C-u>call AppendToFile('SELECT ' . GetSelectionText())<Return>
nmap <buffer> <leader><F1> viw\<F1>

" backslash-then-F8 adds 'SELECT * FROM ' onto current selection and then sends
" to fifo:
vmap <buffer> <leader><F8> :<C-u>call AppendToFile('SELECT * FROM ' . GetSelectionText())<Return>
nmap <buffer> <leader><F8> V\<F8>


" replace '00' with '--', since it's a common typo for me:
ia <buffer> 00 --

" Given a string (usually a keyword) return the common replacement for that
" string
function! PgFlip(str)
	let dic = {
		\ 'delete': 'create',
		\ 'create': 'delete',
		\ 'ENABLE': 'DISABLE',
		\ 'DISABLE': 'ENABLE',
		\ 'SELECT': 'PERFORM',
		\ 'PERFORM': 'EXECUTE',
		\ 'EXECUTE': 'SELECT',
		\ 'SELECT *': 'SELECT COUNT(*)',
		\ 'SELECT COUNT(*)': 'DELETE',
		\ 'DELETE': 'SELECT *',
		\ '*': 'COUNT(*)',
		\ 'COUNT(*)': '*',
		\ 'update': 'insert',
		\ 'insert': 'update',
		\ 'UPDATE': 'INSERT',
		\ 'INSERT': 'UPDATE',
		\ 'MIN': 'MAX',
		\ 'MAX': 'MIN',
		\ 'new': 'old',
		\ 'NEW': 'OLD',
		\ '<>' : 'IS DISTINCT FROM',
		\ '=' : '=ANY(',
		\ '=ANY' : 'IN',
		\ '=ANY(' : 'IN (',
		\ 'IN (' : '=',
		\ 'IN' : '=',
		\ 'true' : 'false',
		\ 'false' : 'true',
		\ 'plpgsql' : 'sql',
		\ 'sql' : 'plpgsql'
	\ }
	return get(dic, a:str, a:str)
endfunction

" Highlight the COMMENT, DO, or CREATE statement in which the cursor currently
" resides, and then press F5 to pipe the text to the outside (see .vimrc for
" details on what that binding does from visual mode):
command! Re normal :set nopaste<Return>mwgZ:echo (search('\%'.line('.').'l^[CD]','b'))? 0 : search('^[CD]','b') <Return>^mugzgzV`u<F5>`w
" ^ This covers CREATE statements, COMMENT statements, and DO statements
Alias re Re

command! Nneo execute "normal! y" . (mode()=='n'? 'iw' : '') . "iOLD.\<C-o>e\<Right> <> NEW.\<C-r>\""
Alias nneo Nneo

" backslash-then-u unlocks/unfreezes pane 0 in the screen session to which we
" are currently attached:
nnoremap <leader>u :call ScreenDo('stuff "^["')<Return>
" backslash-then-e
nmap <leader>e :call ScreenDo('copy') \| call ScreenDo('stuff "?ERR^M"')<Return>

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

function! GetNearestFuncSig(direction)
	let directionFlag = ''
	if a:direction == 'backward'
		let directionFlag = 'b'
	endif
	" Find the start of the previous function-definition:
	let defStart = searchpos(
		\ '\(^\s*CREATE OR REPLACE FUNCTION [a-z][a-z_0-9]*\.\?[a-z][a-z_0-9]*\)\@<=\((\)',
		\ 'n' . directionFlag
	\ )
	" Find the part right before the code-body of that function:
	let defPreBody = searchpos(
		\ ')\_sRETURNS',
		\ 'n' . directionFlag
	\ )
	" " Collect the text found between the two locations:
	let funcName = matchstr(
		\ getline(defStart[0]),
		\ '\(^\s*CREATE OR REPLACE FUNCTION \)\@<=[a-z][a-z_0-9]*\.\?[a-z][a-z_0-9]*'
	\ )
	" Find all of the commas that actually divide the func's parameters:
	let params = ['']
	let curParam = 0
	let curLoc = defStart
	let curLoc[1] += 1
	while curLoc[0] <= defPreBody[0]
		let line = getline(curLoc[0])
		while curLoc[1] <= strlen(line) " using '<=' because curLoc starts at 1
			if curLoc[0] == defPreBody[0] && curLoc[1] >= defPreBody[1]
			" If we're on the last line of interest and we've gone past the
			" terminal column:
				break
			endif
			let char = strpart(line,curLoc[1]-1,1)
			let params[curParam] .= char
			if char == ','
				if synIDattr( synID(curLoc[0], curLoc[1], 1), "name" ) == ''
				" If a real separating comma (outside a string) is found:
					let curLoc[1] += 1
					" Remove trailing comma:
					let params[curParam] = strpart(params[curParam],0,strlen(params[curParam])-1)
					call add(params,'')
					let curParam +=1
				endif
			endif
			let curLoc[1] += 1
		endwhile
		let curLoc[0] += 1
		let curLoc[1] = 0
	endwhile
	let curParam = 0
	while curParam < len(params)
		" Capture the datatype (expected to be uppercase and can end in '[]').
		" Usually, it will appear right before the end of the parameter:
		let terminator = '$'
		if match(params[curParam],'=') != -1
		" if a default was given, the datatype will precede the
		" equals sign instead of the end of the string:
			let terminator = '\( \?=\)\@='
		endif
		let params[curParam] = matchstr(params[curParam],'\u* \?\u\+\(\[\]\)\?' . terminator)
		" Strip any leading and trailing spaces:
		let params[curParam] = substitute(params[curParam],'^\s\+','','')
		let params[curParam] = substitute(params[curParam],'\s\+$','','')
		let curParam +=1
	endwhile
	return funcName . '(' . join(params,', ') . ')'

endfunction

