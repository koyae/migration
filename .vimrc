" Custom Filetypes:
autocmd BufNewFile,BufRead, *.postgre setf pgsql

"--------------------Plugin Imports------------------------:
	:source ~/.vim/plugin/cmdalias.vim

"---------------------User settings------------------------:

"-- Display
	colorscheme koyae
	syntax on
	if exists('+breakindent')
		:set breakindent " paragraphs moved all the way over if there's an indent in front (long line soft wrap)
	endif
	:set linebreak " whole-word wrapping instead of mid-word

"-- I/O
	:set bs=2
	:set mouse=n
	:set gdefault " find-and-replace defaults to global rather than just current line
	:set autoindent " keep the current indentation on new <CR>. Negate with :setlocal noautoindent
	:set splitright " make :vs open on right instead of bumping current pane over
	:set splitbelow " make :split open files on the bottom instead of bumping current pane down
	:set tabstop=4 " make tab-characters display as 4 spaces instead of default 8 
	:set shiftwidth=4 " make '>' (angle bracket) behave itself
	:set ignorecase smartcase "searching is non-case-sensitive unless there's a cap
	:set shellcmdflag=-ic
"- compatability 
	:set nocompatible
	:set <S-Left>=[D
	:set <S-Right>=[C
	:set <C-Left>=OD
	:set <C-Right>=OC

"-- cmdalias.vim aliases
	:Alias Wq wq
	:Alias qw wq
	:Alias Q q
	:Alias W w
	
 
"-------------------Functions------------------------------:

" I use the convention "before" in function names to connote one character before
" In turn "after" means the opposite.
" To connote the LINE before the cursor's current position, I use "above"
" and in turn "below" means the opposite.

" Note that function! forces overwrite if necessary on creation of a funciton	

	" Selects entire document then performs series of keystrokes in normal mode
	function! SelectAllThenDo(keystrokeString)
		normal ggVG
		exec a:keystrokeString
	endfunction

	function! GoopyMalchik()
		call SelectAllThenDo(':call ChangeSqlCase()')
	endfunction

	function! InsertCharAfterCurrentChar(char)
		silent! exec "normal a" . a:char
	endfunction
 	
	function! ToInsertBeforeCurrentChar(char)
		silent! exec "normal a" . "\<Left>". a:char 
		return "i" . a:char . "\<Esc>"
	endfunction

	" Returns a string to insert a new line relative to the current line
	" 
	" preCr		--		a key or combination of keys in the form of a string
	"					to press before <CR> is input, after determining the current line's indent level
	" postCr	--		a key or combination of key in the form of a string
	"					to press after <CR> is input to reorient the cursor appropriately
	"                   for example, ('\<End>\<End>','') would result in the <CR> being placed after whatever's on the current line, while
	"                   ('\<Home>','\<Up>') would insert a line before header charcaters in current line, and then move up
	function! InsertLineSomewhere(preCr,postCr)
		" BOOKMARK
		let indentlevel = matchstr(getline('.'), '\_^\s\+')
		" If Home sent cursor to a \s character then use that character plus everything behind it
		" If Home sent the cursor to an alpha character then use whatever's to the left of that
		" <End>a<CR> and then paste the whitespace characters we had from the beginning of the line. See what happens after that. If the cursor moves to somewhere inappropriate when we leave insert-mode, we can move functionality to "StartInsertingAbove()" and "StartInsertingBelow" and just have O and o insert lame old newlines like they always have (but in our case without entering into insert-mode.
		" Another alternative is to alter the behavior of 'i' so that it checks the above and/or below lines to figure out what to do. It would spam some whitespaces in and then leave you in insert mode as per usual.
		return "i" . a:preCr . "\<CR>" . indentlevel . a:postCr
	endfunction

	" currently unused
	"function! GetCurrentIndentLevel()
		"return matchstr(getline('.'),'\_$\s\+')
	"endfunction

	function! InsertLineBelow()
		return "i\<End>\<End>\<CR>" 
	endfunction

	function! InsertLineAbove()
		" if matchstr(getline('.'),'\(\_^\s\+\)\@<=\S')
		" let indentAmount = GetCurrentIndentLevel()
		return "i\<End>\<Home>\<CR>\<Up>"
	endfunction

	" Smarthome function courtesy http://vim.wikia.com/wiki/Smart_home#More_features
	function! SmartHome()
		let first_nonblank = match(getline('.'), '\S') + 1
		if first_nonblank == 0
			return col('.') + 1 >= col('$') ? '0' : '^'
		endif
		if col('.') == first_nonblank
			return '0'  " if at first nonblank, go to start line
		endif
		return &wrap && wincol() > 1 ? 'g^' : '^'
	endfunction

	"function! ToReplaceWithinSelection()
		"return "%s/\
	"endfunction

" helper-function
    function! AtEndOfLine()
        let textAfterCursor = strpart(getline('.'),col('.'))
        if textAfterCursor==""
            return 1
        endif
        return 0
    endfunction

" helper-function: return whether there's only whitespace on a line or not
	function! OnlyWhitespaceOnLine()
		let onlySpace = match(getline('.'),'\_^\s\+\_$')
		let blankLine = match(getline('.'),'\_^\_$')
		if onlySpace==-1 && blankLine==-1
		" If line is not blank and also does not just contain whitespace
			return 0
		else
		" If line has stuff in it
			return 1
		endif
	endfunction

" nnoremapped to <Return>
    function! ToInsertCr()
        "let indentLevel = GetCurrentIndentLevel()
        if AtEndOfLine()
            return "a\<CR>\<Space>\<Esc>"
        endif
        return "i\<CR>\<Esc>"
    endfunction

" nnoremaped to <Del>    
    function! SmartDelete()
        return AtEndOfLine()? "a\<Del>\<Esc>" : "x"
    endfunction

	function! SmartX()
		return OnlyWhitespaceOnLine()? SmartDelete() : "x"
	endfunction

"---------------------Novel keybindings--------------------: 
	" ctrlPageUp goes to next tab:
	noremap <silent> <C-PgUp> gT
	" ctrlPageDown goes to previous tab:
	noremap <silent> <C-PgDown> gt
	" ctrlUp swaps current line with above
	nnoremap <C-Up> dd<Up><S-p>
	" ctrlDown swaps current line with below
	nnoremap <C-Down> ddp
	noremap <C-q> :q
	" ctrl9 jumps to matching parenthesis when one is selected, just like % does
	noremap <C-9> %
	" ctrl0 jumps to matching parenthesis when one is selected, just like % does
	noremap <C-0> %
	
"-- Find and replace stuff

	" ctrlF opens search mode
	nnoremap <C-f> /
	" normal ctrlH starts a document-wide replace
	nnoremap <C-h> :%s/
	" visual ctrlH starts replacement within selection
	vnoremap <C-h>  :s/
	" ctrlR replaces the selected text:
	vnoremap <C-r> "hy:%s/<C-r>h//<left>
	" credit: http://stackoverflow.com/questions/676600/

"-------------------Keybinding overrides-------------------:

"-- Smarthome bindings:
	noremap <expr> <silent> <Home> SmartHome()
	imap <silent> <Home> <C-O><Home>
	noremap <expr> <Home> (col('.') == matchend(getline('.'), '^\s*')+1 ? '0' : '^')
	noremap <expr> <End> (col('.') == match(getline('.'), '\s*$') ? '$' : 'g_')
	vnoremap <expr> <End> (col('.') == match(getline('.'), '\s*$') ? '$h' : 'g_')
	imap <Home> <C-o><Home>
	imap <End> <C-o><End>
	 
	"2: o-key and shiftO insert a line below or above the current one (without staying in insert mode)
	" the x below deletes the autoindent whitespace 2:
	nmap <silent> <expr> o InsertLineBelow() . "\<Esc>"
	nmap <silent> <expr> O InsertLineAbove() . "\<Esc><C-Del>"

	nmap <Up> gk
	nmap <Down> gj
	vmap <Up> gk
	vmap <Down> gj
	" 2^ wrap according to what's shown on screen versus using \n 

	" z-key undo:
	nmap z u
	" shiftU redoes:
	nmap U <C-r>
	" shiftZ redoes:
	nmap Z <C-r>
	" insert-key enters replace-mode
	nnoremap <Insert> i<Insert>

	" shiftU capitalizes SQL keywords: 
	vnoremap <silent> U :call ChangeSqlCase() <Return><Return>
 	" ctrlU capitalizes any alphas in selection:
	vnoremap <silent> <C-u> U
	" ctrlShiftU lowercases any alphas in selection:
	vnoremap <silent> <C-U> u 

"-- Selection stuff

	" shiftRight starts visual selection to the right
 	nmap <S-Right> v<Right>
	" shiftLeft starts visual selection to the left
	nmap <S-Left> v<Left>
	" allow shiftLeft to stay held while selecting without jumping by word
	vmap <S-Left> <Left>
	" allow shiftRight to stay held while selecting without jumping by word
	vmap <S-Right> <Right>
	" ctrlRight jumps by word like in most text editors:
	vnoremap <C-Right> <S-Right>
	" ctrlLeft jumps by word like in most text editors:
	vnoremap <C-Left> <S-Left>
	":4 sadly the previous two aliases do not quite work in PuTTY 
  
"-- Normal-mode passthroughs for 

	" backslash-key, forwardslash-key, double-quote-key
	nmap <silent> <expr> / ToInsertBeforeCurrentChar('/')
	nmap <silent> <expr> \ ToInsertBeforeCurrentChar('\')
	nmap <expr> <silent> " ToInsertBeforeCurrentChar('"') 
	" space makes a space before current character:
	noremap <silent> <expr> <Space> ToInsertBeforeCurrentChar(" ")
	" enter-key acts like enter:
	nmap <silent> <expr> <Return> ToInsertCr()
	"inoremap <silent> <expr> <Return> ToInsertCr()
	" 3: shiftI, 8-key and 9-key begin insert above 3:
	nmap <silent> <expr> <S-i> InsertLineAbove()
	nmap <silent> <expr> 8 InsertLineAbove()
	nmap <silent> <expr> 9 InsertLineAbove()
	" k-key begins insert below:
	nmap <silent> <expr> k InsertLineBelow()   
	"<A-i> i\<End>\<End>\<CR>
	" tab-key indents current line
	nmap <Tab> i<Home><Tab><Esc><Home>
	" backspace-key deletes one character back 
	nmap <BS> i<BS><Esc><Right>
	" delete-key acts like x unless at end of line
	nnoremap <silent> <expr> <Del> SmartDelete()  
	nnoremap <silent> <expr> x SmartX()
	" ctrlDelete deletes rest of line
	nmap <C-kDel> v<S-$><Left>x 


