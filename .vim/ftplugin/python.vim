" Only do this when not done yet for this buffer
"if exists("b:did_ftplugin")
"  finish
"endif
":let b:did_ftplugin = 1

" set comments to display in red:
:Comred

" FindFuncBottomPython(fromLine)
" Search forward from `fromLine` to locate bottom of function
function! FindFuncBottomPython(fromLine)
	let startnr = s:Line(a:fromLine)
	let lastSubordinate = -1
	if AtFuncTopPython(startnr)
	" base case:
		let minIndent = matchstr(getline(startnr),'^\s*')
		let linenr = startnr
		let jumpTo = linenr
		while linenr<=line('$')
			let linenr += 1
			let line = getline(linenr)
			let isWhite = match(linenr,'\S')==-1 || line==""
			if matchstr(line,'^\s*')>minIndent
			" if greater identation on the checked line, it belongs to the
			" function:
				let lastSubordinate = linenr
			elseif !isWhite
			" if equal or lesser indentation and not an all-whitespace line,
			" break out of the loop:
				echom "Squad broken at " . linenr
				break
			endif
		endwhile
	else
	" recurse once if we're not at an anchor:
		let lastSubordinate = FindFuncBottomPython(FindFuncTopPython(a:fromLine,1))
	endif
	return lastSubordinate
endfunction

" ToFuncBottomPython(fromLine)
" Return keystrokes to go to the last line of a function, (assuming nothing is
" bogus with indentation):
function! ToFuncBottomPython(fromLine,recurse)
	let startnr = s:Line(a:fromLine)
	let rrval = FindFuncBottomPython(a:fromLine)
	if rrval==startnr && a:recurse
		return ToFuncTopPython(a:fromLine,1,0)
	endif
	if rrval==startnr || rrval==-1
		let rrval = FindFuncBottomPython(startnr+1)
		if rrval==startnr || rrval==-1
			return ""
		endif
	endif
	return rrval . 'gg'
endfunction

" Find the start of the nearest function from the given line, returning -1 on
" failure.
function! FindFuncTopPython(fromLine,backward)
	let linenr = s:Line(a:fromLine)
	let increment = a:backward? -1 : 1
	while ((a:backward)? linenr>=1 : linenr<=line('$'))
		if AtFuncTopPython(linenr)
			return linenr
		endif
		let linenr += increment
	endwhile
	return -1
endfunction

" ToFuncTopPython()
" Return keystrokes to go to the top of the nearest function:
function! ToFuncTopPython(fromLine,recurse,backward)
	let targetLine = FindFuncTopPython(a:fromLine,a:backward)
	if targetLine==s:Line(a:fromLine) && a:recurse
		" recurse once by just backing up one line if we're already on a
		" matching line:
		return ToFuncTopPython(s:Line(a:fromLine)-1,0,a:backward)
	endif
	if targetLine==-1
	" if no results
		echom "Failed"
		return ""
	else
		echom "Succ'd"
		return targetLine . 'gg'
	endif
endfunction

" Given a reference to a line-number (e.g. '.', 27, 586) return an absolute
" line-number:
function! s:Line(lineref)
	return match(a:lineref,'\d\+')!=-1? a:lineref : line(a:lineref)
endfunction

function! AtFuncTopPython(line)
	return match(getline(a:line), '^\s*def\>')!=-1
endfunction


nnoremap <buffer> <expr> gz ToFuncBottomPython('.',1)
vnoremap <buffer> <expr> gz ToFuncBottomPython('.',1)

nnoremap <buffer> <expr> gZ ToFuncTopPython('.',1,1)
vnoremap <buffer> <expr> gZ ToFuncTopPython('.',1,1)

" alt3 comments out:
vnoremap <buffer> 3 :TComment!<Return>
nnoremap <buffer> 3 :TComment!<Return>

" alt2 comments in:
vnoremap <buffer> 2 :TComment<Return>
nnoremap <buffer> 2 :TComment<Return>

" alt4 comments in:
vnoremap <buffer> 4 :TComment<Return>
nnoremap <buffer> 4 :TComment<Return>
