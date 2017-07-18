" Custom handling by filetype:
autocmd BufNewFile,BufRead, *.postgre setf pgsql
autocmd BufNewFile,BufRead, pom.xml,web.xml set tabstop=2 expandtab shiftwidth=2
autocmd BufNewFile,BufRead, .gitconfig* setf gitconfig
" allow PHP comments to rewrap correctly:
autocmd Syntax, php set comments+=://

"--------------------Compatibility settings----------------:
	:set nocompatible
	:set <S-Left>=[D
	:set <S-Right>=[C
	:set <C-Left>=OD
	:set <C-Right>=OC
	:set <A-=>==
	:set <A-z>=z
	:set <A-s>=s
	:set <A-(>=9
	:set <A-)>=0
	:set <C-A-x>=
	:set <C-A-t>=
	:set <A-d>=d
	:set <A-i>=i

	let term=$TERM
	if term == 'screen'
	" if running from `screen`, assume xterm-signals:
		:set term=xterm
	endif

"--------------------Plugin Imports------------------------:
	:source ~/.vim/plugin/cmdalias.vim
	execute pathogen#infect()

"---------------------User settings------------------------:

"-- Display
	colorscheme koyae
	syntax on
	let g:is_posix=1 " this will be right on 99% of systems
	if exists('+breakindent')
		:set breakindent " paragraphs moved all the way over if there's an indent in front (long line soft wrap)
	endif
	:set linebreak " whole-word wrapping instead of mid-word

"-- I/O
	:set bs=2
	:set mouse=n
	:set ttymouse=sgr
	:set gdefault " find-and-replace defaults to global rather than just current line
	:set autoindent " keep the current indentation on new <CR>. Negate with :setlocal noautoindent
	:set splitright " make :vs open on right instead of bumping current pane over
	:set splitbelow " make :split open files on the bottom instead of bumping current pane down
	:set tabstop=4 " make tab-characters display as 4 spaces instead of default 8 
	:set shiftwidth=0 " make '>' (angle bracket) always just match `tabstop`
	:set ignorecase smartcase "searching is non-case-sensitive unless there's a cap
	:set shellcmdflag=-ic

"-- Formatting behavior:
	:set formatoptions+=j " allow vim's re-wrapping functionality to join as well as split
	:set formatoptions-=r " don't repeat the single-line comment symbol when pressing enter

"-- cmdalias.vim aliases
	:Alias Wq wq
	:Alias WQ wq
	:Alias qw wq
	:Alias Q q
	:Alias W w
	:command! Reup source ~/.vimrc
	:Alias reup Reup
 
"-------------------Functions------------------------------:

" I use the convention "before" in function names to connote one character before
" In turn "after" means the opposite.
" To connote the LINE before the cursor's current position, I use "above".
" In turn "below" means the opposite.

" Note `function!` forces overwrite if necessary on creation of a funciton	

	function! PaneToTab()
		let buffer_number = bufnr('%')
		close
		tabedit
		execute "buffer " . buffer_number
	endfunction

	function! EatNextWord()
		normal! m'v
		call search('\s*[_a-zA-Z]\+\s*', 'ce', getline('.'))
		normal! "_x
		normal! `'
	endfunction

	" Selects entire document then performs series of keystrokes in normal mode
	function! SelectAllThenDo(commandString)
		normal ggVG
		exec a:commandString
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

	function! InsertAtEOL(str,cleanEnd)
		if a:cleanEnd
			execute "normal! :s/\\s\\+$//e\<Return>"
		endif
		execute "normal! i\<End>" . a:str . "\<Esc>"
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

 
" helper-function: return booleanishly to indicate whether there are multiple
" lines selected:
	function! MultipleLinesSelected()
		" if the start of the active selection is on a different line than the
		" end of it:
		return line("v") != line(".")
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
		" Delete the whole line if we have only whitespace and it is the only
		" line in question. Otherwise, delete everything in the selection:
		if MultipleLinesSelected()==1
			return '"_x'
		else
			return OnlyWhitespaceOnLine()? 'V"_x' : '"_x'
		endif
	endfunction
	
	function! SmartS()
		let keySequence = '"_xi'
		" If replacing (characters up to) the last character, make sure to
		" insert starting from the first column that was replaced, rather than
		" sometimes one back from that:
		return AtEndOfLine()? keySequence . "\<Right>" : keySequence
	endfunction

	function! SaveSetting(settingName)
		let estring = "let t:" . a:settingName . " = &" . a:settingName
		exec estring
	endfunction

	function! RestoreSetting(settingName)
		let estring = "let &" . a:settingName . " = t:" . a:settingName
		exec estring
	endfunction

	function! JumpToChar(character,flags)
		let char=a:character
		if char == ''
			let char = g:foundLast		
		else
			let g:foundLast = a:character
		endif
		call SaveSetting('ignorecase')
		call SaveSetting('smartcase')
		let &ignorecase = 0
		let &smartcase = 0
		call search('\V' . char, 'w'. a:flags)
		call RestoreSetting('ignorecase')
		call RestoreSetting('smartcase')
	endfunction

	function! JumpToNextMatchingChar(flags)
		let char = matchstr(getline('.'), '\%' . col('.') . 'c.')
		call JumpToChar(char,a:flags)
	endfunction

	" Interactive character-jump function
	function! FindChar(flags)
		let char = nr2char( getchar() )
		call JumpToChar(char,a:flags)
	endfunction

"---------------------Novel keybindings--------------------:

" ctrlAltT tears out current pane and sends to a new tab:
	nnoremap <C-A-t> :call PaneToTab()<Return>

	" ctrlPageUp goes to next tab:
	noremap <silent> <C-PgUp> gT
	" ctrlPageDown goes to previous tab:
	noremap <silent> <C-PgDown> gt
	" altDown swaps current line(s) with below, keeping selection if needed:
	nnoremap <A-Up> dd<Up><S-p>
	vnoremap <A-Up> d<Up><S-p>`[V`]
	" altUp swaps current line(s) with above, keeping selection if needed:
	nnoremap <A-Down> ddp
	vnoremap <A-Down> d<Down><End>p`[V`]
	" ctrlUp scrolls screen up one line without moving cursor:
	noremap <C-Up> <C-y>
	" ctrlDown scrolls screen down one line without moving cursor:
	noremap <C-Down> <C-e>
	" ctrlQ attempts to quit vim:
	noremap <C-q> :qa<Return>
	" ctrlX deletes current line:
	nnoremap <C-x> Vx
	inoremap <C-x> <C-o>Vx
	" ctrlAltX deletes all lines:
	noremap <silent> <C-A-x> :call SelectAllThenDo("normal x")<Return>
	" ctrlS saves current file:
	nnoremap <C-s> :w <Return>
	" ^ Note that many shell-clients bind ctrlS to send the freeze-output 
	" signal (XOFF). This command won't work if that's not done. In most cases
	" it can be disabled from .bashrc
	
	" altS clears trailing whitespace if present then places a semicolon at EOL:
	nnoremap <silent> <A-s> :call InsertAtEOL(';',1)<Return> 
	" alt-0 clears trailing whitespace if present then places ')' at EOL:
	nnoremap <silent> <A-)> :call InsertAtEOL(')',1)<Return>
	" openParen surrounds current selection in parentheses from visual mode:
	vnoremap <silent> ( <Esc>`<i(<Esc>`><Right>a)<Esc>
	" closeParen does the same as above:
	vnoremap <silent> ) <Esc>`<i(<Esc>`><Right>a)<Esc>
	
	" altI adds '>' to the beginning of lines:
	vmap <A-i> :s/^./>\0/<Return>:noh <Return>
	nmap <A-i> :%s/^./>\0/<Return>:noh <Return>
	" altEquals adds a space after (sequences of) '>' which begin a line:
	vmap <A-=> :sm/^\(>\+\)\([^ >]\)/\1 \2/ <Return>:noh <Return>
	nmap <A-=> :%sm/^\(>\+\)\([^ >]\)/\1 \2/ <Return>:noh <Return>

"-- Find and replace stuff

	" ctrlF opens search mode:
	nnoremap <C-f> /
	" normal ctrlH starts a document-wide replace:
	nnoremap <C-h> :%s/
	" visual ctrlH starts replacement within selection:
	vnoremap <C-h>  :s/
	" ctrlR replaces the selected text:
	vnoremap <C-r> "hy:%s/<C-r>h//<left>
	" credit: http://stackoverflow.com/questions/676600/
	vmap <Return> <Del>
	
	" f-key finds the next single character (accepted afterwards
	" interactively) on multiple lines, rather than just the current one:
	nnoremap <silent> f :call FindChar('')<Return>
	" shiftF finds previous single character (accepted afterwards
	" interactively)
	nnoremap <silent> F :call FindChar('b')<Return>
	nnoremap <silent> ; :call JumpToChar('','')<Return>
	nnoremap <silent> , :call JumpToChar('','b')<Return>

"-------------------Keybinding overrides-------------------:

"-- Emmet bindings:
	" altZ expands tags instead of Emmet's default two-step shortcut ctrlY-then-,
	imap <A-z> <C-Y>,

"-- Smarthome bindings:
	noremap <expr> <silent> <Home> SmartHome()
	imap <silent> <Home> <C-O><Home>
	noremap <expr> <Home> (col('.') == matchend(getline('.'), '^\s*')+1 ? '0' : '^')
	noremap <expr> <End> match( getline('.'), '\s\+$' ) != -1 ? 'g_<Right>' : 'g_'
	vnoremap <expr> <End> (col('.') == match(getline('.'), '\s\+$') ? '$h' : 'g_')
	imap <Home> <C-o><Home>
	" Always place the cursor 1 column right of the last non-whitespace: 
	imap <End> <C-o>g_<Right>
	 
	"2: o-key and shiftO insert a line below or above the current one (without staying in insert mode)
	" the x below deletes the autoindent whitespace 2:
	nmap <silent> <expr> o InsertLineBelow() . "\<Esc>"
	nmap <silent> <expr> O InsertLineAbove() . "\<Esc><C-Del>"

	nmap <Up> gk
	nmap <Down> gj
	vmap <Up> gk
	vmap <Down> gj
	imap <Up> <C-o>gk
	imap <Down> <C-o>gj
	" 6^ wrap according to what's shown on screen versus using" 2^ wrap according to what's shown on screen versus using \n 

	" s-key does not yank, just deletes then enters insert-mode:
	vnoremap <expr> s SmartS()
	" x-key does not yank, just deletes:
	vnoremap <expr> x SmartX()

	" shiftU redoes:
	nmap U <C-r>
	" insert-key enters replace-mode
	nnoremap <Insert> i<Insert>

	" shiftU capitalizes SQL keywords: 
	vnoremap <silent> <C-u> :call ChangeSqlCase() <Return><Return>
 	" U-key capitalizes any alphas in selection:
	vnoremap <silent> U gU
	" u-key lowercases any alphas in selection:
	vnoremap <silent> u gu 


"-- Selection stuff

	" shiftRight starts visual selection to the right:
 	nmap <S-Right> v<Right>
	" shiftLeft starts visual selection to the left:
	nmap <S-Left> v<Left>
	" ctrlShiftRight starts visual selection by word to the left:
	nmap <C-S-Right> v<C-Right>
	" ctrlShiftLeft starts visual selection by word to the left:
	nmap <C-S-Left> v<C-Left>
	" allow shiftLeft to stay held while selecting without jumping by word
	vmap <S-Left> <Left>
	" allow shiftRight to stay held while selecting without jumping by word
	vmap <S-Right> <Right>
	" ctrlRight keeps the cursor on the right side of words when jumping:
	nnoremap <C-Right> <C-Right>he
	" ctrlRight jumps by word like in most text editors:
	vnoremap <C-Right> <S-Right>
	" ctrlLeft jumps by word like in most text editors:
	vnoremap <C-Left> <S-Left>
	":4 sadly the previous two aliases do not quite work in PuTTY

	" j-key jumps to the next character which matches the one under the
	" cursor:
	nnoremap <silent> j :call JumpToNextMatchingChar('')<Return>

	" ctrlBackspace deletes previous word:
	nmap  i<C-w><Esc>x 

	" altD eats next word / deletes next word:
	nnoremap <silent> <A-d> :call EatNextWord() <Return>
	inoremap <silent> <A-d> <Right><Esc>:call EatNextWord() <Return>i

	" ctrlA does select all:
	nnoremap <C-a> gg<S-v>G

"-- Normal-mode passthroughs for 

	" backslash-key, forwardslash-key, double-quote-key
	for v in ["javascript","php","java","c","cpp","cs"]
		let cmdstr = "autocmd Syntax, " . v . " nmap <silent> <expr> "
		let cmdstr = cmdstr . "/ ToInsertBeforeCurrentChar('/')"
		execute cmdstr 
	endfor
	nmap <silent> <expr> \ ToInsertBeforeCurrentChar('\')
	autocmd Syntax, vim nmap <expr> <silent> " ToInsertBeforeCurrentChar('"') 
	" space inserts a space in front of current character:
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
