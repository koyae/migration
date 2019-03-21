" Only do this when not done yet for this buffer
"if exists("b:did_ftplugin")
"  finish
"endif
":let b:did_ftplugin = 1

" set comments to display in red:
hi Comment ctermfg=Red


function! CommentX(replacecmd)
	let dostring = a:replacecmd
	let dostring = '.,.' . l:dostring
	exec dostring
endfunction


function! CommentOut()
	let rval = CommentX("s/\\_^/## /")
endfunction


function! CommentIn()
	let rval = CommentX("s/\\_^## //")
endfunction


" alt3 comments out:
vnoremap <silent> 3 :call CommentOut() <Return><Return>
nnoremap <silent> 3 :call CommentOut() <Return><Return>

" alt2 comments in:
vnoremap <silent> 2 :call CommentIn() <Return><Return>
nnoremap <silent> 2 :call CommentIn() <Return><Return>

" alt4 comments in:
vnoremap <silent> 4 :call CommentIn() <Return><Return>
nnoremap <silent> 4 :call CommentIn() <Return><Return>
