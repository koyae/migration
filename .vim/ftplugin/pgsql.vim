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

noremap <buffer> gk /\(^\s*\)\@<=\(INSERT\\|SELECT [^1]\\|DELETE\\|PERFORM\\|WITH\)<Return>
noremap <buffer> gK ?\(^\s*\)\@<=\(INSERT\\|SELECT [^1]\\|DELETE\\|PERFORM\\|WITH\)<Return>

" backslash-then-d-then-f documents function under cursor:
vmap <buffer> <leader>df :<C-u>call AppendToFile('\df ' . GetSelectionText())<Return>
nmap <buffer> <leader>df viw\df

" backslash-then-d-then-r documents relation under cursor:
vmap <buffer> <leader>dr :<C-u>call AppendToFile('\d ' . GetSelectionText())<Return>
nmap <buffer> <leader>dr viw\dr

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
		\ 'PERFORM': 'SELECT',
		\ 'update': 'insert',
		\ 'insert': 'update',
		\ 'UPDATE': 'INSERT',
		\ 'INSERT': 'UPDATE',
		\ 'MIN': 'MAX',
		\ 'MAX': 'MIN',
		\ 'new': 'old',
		\ 'NEW': 'OLD',
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
" Unfreeze pane 0 in the screen session to which we are currently attached,
" then have vim redraw since running commands under `silent exec` screw up
" vim's display:
nnoremap <leader>u :silent exec '!screen -dr $(screen -wipe \| grep "Attached" \| cut -f 2) -p 0 -X stuff "^["; fg'<Return>:redraw!<Return>

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

function! SliceRagged(areaOfInterest,prevLoc,curLoc)
	let rval = a:areaOfInterest[a:prevLoc[0]:a:curLoc[0]]
	echom string(a:prevLoc) . ".." . string(a:curLoc)
	if a:prevLoc[0] != a:curLoc[0]
	" if the params are on different lines, wipe everything on the last line
	" that comes after the current position
		echom "Diff"
		let rval[-1] = strpart(rval[-1], 0, a:curLoc[1])
	else
	" if the params are on the same line, we only want the stuff that comes AFTER
	" the previous position UP UNTIL the current position:
		echom "Same"
		let rval[0] = strpart(rval[0], a:prevLoc[1]-1, a:curLoc[1]-a:prevLoc[1])
	endif

	" if the params are on the same line
	return rval
endfunction

function! GetPreviousFuncSig(...)
	let fromLine = (a:0==0)? '.' : a:1
	" Find the start of the previous function-definition:
	let defStart = searchpos(
		\ '\(^\s*CREATE OR REPLACE FUNCTION [a-z_0-9]\+\)\@<=\((\)',
		\ 'bn'
	\ )
	" Find the part right before the code-body of that function:
	let defPreBody = searchpos(
		\ ')\_sRETURNS',
		\ 'bn'
	\ )
	" " Collect the text found between the two locations:
	" let areaOfInterest = getline(defStart[0], defPreBody[0])
	" let areaOfInterest[0] = strpart(areaOfInterest[0],defStart[1])
	" let areaOfInterest[-1] = strpart(areaOfInterest[-1],0,defPreBody[1])
	" let @a = join(areaOfInterest,"\n")
	" Find all of the commas that actually divide the func's parameters:
	let params = ['']
	let curParam = 0
	let curLoc = defStart
	let curLoc[1] += 1
	while curLoc[0] <= defPreBody[0]
		let line = getline(curLoc[0])
		while curLoc[1] < strlen(line)
			if curLoc[0] == defPreBody[0] && curLoc[1] >= defPreBody[1]
				break
			endif
			let char = strpart(line,curLoc[1]-1,1)
			let params[curParam] .= char
			if char == ','
				" If a real comma is found:
				echom "Comma found at " .
					\ string(curLoc)
				if synIDattr( synID(curLoc[0], curLoc[1], 1), "name" ) == ''
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
	echom string(params)
	let curParam = 0
	while curParam < len(params)
		let	params[curParam] = matchstr(params[curParam],'\(\u \)*\u\+$')
		let curParam +=1
	endwhile
	echom string(params)
endfunction

