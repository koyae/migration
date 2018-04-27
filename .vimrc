" Strip trailing whitespace on save:
autocmd BufWritePre * :%s/\s\+$//e
" Custom handling by filetype:
autocmd BufNewFile,BufRead, *.postgre.sql setf pgsql
autocmd BufNewFile,BufRead, pom.xml,web.xml set tabstop=2 expandtab shiftwidth=2
autocmd BufNewFile,BufRead, .gitconfig* setf gitconfig
autocmd BufNewFile,BufRead, .screenrc* setf screen
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
	:set <C-A-q>=
	:set <A-d>=d
	:set <A-i>=i

	let term=$TERM
	if term == 'screen' || term == "screen-256color" || term == "xterm-256color"
	" if running from `screen`, assume xterm-signals:
		:set term=xterm
	endif

"--------------------Plugin Imports------------------------:
	:source ~/.vim/plugin/cmdalias.vim
	execute pathogen#infect()
	runtime macros/matchit.vim " allow jumping to matching XML tags using '%'

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
		return "i\<C-o>$\<CR>"
	endfunction

	function! InsertLineAbove()
		" if matchstr(getline('.'),'\(\_^\s\+\)\@<=\S')
		" let indentAmount = GetCurrentIndentLevel()
		return "i\<End>\<Home>\<CR>\<Up>"
	endfunction


	" Function adapted from http://vim.wikia.com/wiki/Smart_home#More_features
	function! SmartHome(mode)
		" if the cursor is not at the virtual home, hard home, or soft home,
		" send it to the virtual home
		"
		" if the cursor is at the virutal home but is not at the line's soft
		" home, send it there.
		"
		" if the cursor is at the line's hard home, send it to the line's soft
		" home.
		"
		" Virtual home: the leftmost location of the screen accessible by the
		" cursor without it changing lines visually. This is only different
		" from the 'hard' home if the line is long enough that vim wraps it
		" and will always match the hard home if 'nowrap' is set.
		"
		" Soft home: the leftmost absolute column (not visual) the cursor can
		" visit on the current nonvisual line before reaching a whitespace.
		"
		" Hard home: the leftmost absolute column on the current nonvisual
		" line.
		let orig_pos = col('.')
		let vorig_pos = virtcol('.')
		let virtual_home = 1 + vorig_pos - vorig_pos%winwidth('%') + &tabstop*len(matchstr(getline('.'),'^\t*'))
		let soft_home = match(getline('.'), '\S') + 1
		let hard_home = 1
		" echom "orig: " . orig_pos . " vorig: " . vorig_pos . " virth: " . virtual_home . " softh: " . soft_home
		if vorig_pos != virtual_home && orig_pos != hard_home && orig_pos != soft_home
			return 'g^'
		elseif vorig_pos == virtual_home && orig_pos != soft_home
			return '^'
		elseif orig_pos == soft_home
			return '0'
		elseif orig_pos == hard_home
			return '^'
		endif
	endfunction

	" Capitalize the character under the cursor if it is a Postgres keyword
	" Currently only works from normal mode.
	"
	" The easiest way to use this function for the moment is with the
	" following invocation, starting with the cursor on the first line on
	" which capitalization should start.
	"
	" :exec 'silent! normal!' . To('$','$','.',1,'',":call PgCap()\<Enter>")
	function! PgCap(...)
		let kwType = synIDattr(  synID( line('.'), col('.'), 1 ), "name"  )
		if a:0
			set syntax=pgsql
		elseif a:0==2
			set syntax=pgsql
			let kwType = synIDattr(  synID( a:1, a:2, 1 ), "name"  )
		elseif a:0==1
			let kwType = a:1
		endif
		if index(['pgsqlKeyword','pgsqlOperator'],l:kwType) >= 0
			normal! vgU
		endif
	endfunction

	" To(toLine,toColumn[,fromLine='.'[,luddite=false,lineInject='',colInject='']])
	" Return the keystrokes for moving the cursor to the specified line+column
	function! To(line,toCol,...)
		let toLine = (type(a:line)==v:t_number)? a:line : line(a:line)
		let fromLine = get(a:, 1, '.')
		let fromLine = (type(l:fromLine)==v:t_number)? l:fromLine :	line(l:fromLine)
		let luddite = get(a:, 2, 0)
		let lineInject = get(a:, 3, '')
		let colInject = get(a:, 4, '')
		let rString = ''
		let fromCol = '.'
		if l:luddite
"			echom l:lineToBe . ' -> ' . l:toLine
			let lineToBe = l:fromLine
			" ^ This is the line we expect to land on after each set of actions
			let postInject = ''
			if l:fromLine < l:toLine
			" If we'll be moving to a lower line from the current position...
				" first allow the cursor to move to the end of the line:
				let rString = ToCol(
				\	[l:lineToBe,'$'], l:fromCol, 1, l:colInject
				\ )
				" for subsequent lines, we'll always start from the first
				" column, and will inject a '0' keystroke after moving down
				" each line to make sure of this:
				let fromCol = 1
				let postInject = '0'
				while l:lineToBe < l:toLine - 1
				" for as long as we have not accumulated enough actions to get
				" us to the penultimate line yet, accumulate more actions:
					let rString = l:rString
						\ . ToLine(l:lineToBe + 1, l:lineToBe, 1, l:lineInject, '0')
						\ . ToCol([l:lineToBe + 1,'$'], l:fromCol, 1, l:colInject)
					let fromCol = 1
					let lineToBe += 1
				endwhile
				" Handle last line separately
				let rString = l:rString
					\ . ToLine(
					\	l:toLine, l:lineToBe, 1, l:lineInject, l:postInject
					\ ) . ToCol([l:lineToBe + 1,a:toCol], l:fromCol, 1, l:colInject)
			else
			" If we're already on the right line, we just need to navigate to
			" the desired column:
				"echom "LOGIC"
				let rString = ToCol(
				\	[l:toLine,a:toCol], l:fromCol, 1, l:colInject
				\ )
			endif
		else
			let rString = ToLine(l:toLine, l:fromLine, 0, l:lineInject)
				\ . ToCol(a:toCol, 1, 0, l:colInject)
		endif
		return l:rString
	endfunction

	" ToLine(toLine[,fromLine='.'[,luddite=false,inject=''[,postInject='']]])
	" Return the keystrokes for moving the cursor to the specified line
	" (normal/visual mode)
	function! ToLine(line,...)
		" Copy value and handle specials if necessary:
		let toLine = (type(a:line)==v:t_string)? line(a:line) : a:line
		let fromLine = get(a:, 1, '.')
		" Handle specials if necessary:
		if type(l:fromLine) == v:t_string
			let fromLine = line(l:fromLine)
		endif
		let luddite = get(a:, 2, 0)
		let inject = get(a:, 3, '')
		let postInject = get(a:, 4, '')
		if l:toLine == l:fromLine
			return '' . l:postInject
		else
			if l:luddite
				let difference = l:toLine - l:fromLine
				if l:difference > 0
					return repeat(l:inject . 'j' . l:postInject, l:difference)
				else
					return repeat(l:inject . 'k' . l:postInject, abs(l:difference))
				endif
			else
				return l:inject . l:toLine . 'gg' . l:postInject
		endif
	endfunction

	" ToCol(toCol[,fromCol='.'[,luddite=false[,inject='']]])
	" Return the keystrokes for moving the cursor to the specified column
	" (normal/visual mode)
	" Function assumes we are already on the same line.
	" If not, see ToLine()
	"
	" luddite  --  hit 'r' or 'h' repeatedly (repeating `inject` action each
	"              time) rather than jumping straight to the desired column
	"
	" inject   --  before each navigation-action, execute this string of
	"              keystrokes. If `luddite`=0 this will occur once.
	"              If `luddite`=true this will occur for each column between
	"              the current cursor-position and the target column `toCol`
	"
	function! ToCol(col,...)
		" Copy and handle specials if necessary:
		let toCol = ColTidy(a:col)
		let fromCol = ColTidy(get(a:, 1, '.'))
		let luddite = get(a:, 2, 0)
		let inject = get(a:, 3, '')
		if l:luddite
			let difference = l:toCol - l:fromCol
"			echom 'difference: ' . l:difference
			if l:difference > 0
				return repeat(l:inject . 'l', l:difference)
			else
				return repeat(l:inject . 'h', abs(l:difference))
			endif
		else
			return l:inject . l:toCol . '|'
		endif
	endfunction

	" Helper function for getting valid column-numbers back, assuming
	" navigation in normal mode.
	" Takes a column-number, column string ('^','$', or '.'), or a list in the
	" form [line,column] and returns an integer
	function! ColTidy(col)
		if type(a:col)==v:t_list
			let colNumber = (type(a:col[1])==v:t_number)?
				\ a:col[1] : col(a:col)
			if l:colNumber > len(getline(a:col[0]))
				" Prevent columns past EOL being used:
				return len(getline(a:col[0]))
			else
				" Prevent column 0 being used:
				return max([1,a:col[1]])
			endif
		elseif type(a:col)!=v:t_number
			if a:col=='$'
				" Prevent columns past EOL being used:
				return col('$') - 1
			elseif a:col=='^'
				" Prevent column 0 being used:
				return col('^') + 1
			else
				" Otherwise, we should be in bounds so go for it:
				return col(a:col)
			endif
		else
		" If we're not given a line-number, we just assume it's in bounds:
			return a:col
		endif
	endfunction

	if exists("*synstack")
		function! SynStack()
			echo map(synstack(line('.'),col('.')), 'synIDattr(v:val, "name")')
		endfunction
		" From :help synID:
		function! CurSyn()
			return synIDattr(synID(line('.'),col('.'),1),"name")
		endfunction
	endif

	function! SmartEnd(mode)
		if exists('+belloff')
			call SaveSetting('belloff')
			set belloff=all
		endif
		let orig_pos = virtcol('.')
		let virtual_end = 0
		if orig_pos < winwidth('%')
			let virtual_end = col('$')
		else
			let virtual_end = orig_pos + winwidth('%') - 1
			let virtual_end = virtual_end - virtual_end%winwidth('%')
		endif
		if orig_pos == virtual_end
			return '$'
		else
			return 'g$'
		endif
		if exists('+belloff')
			call RestoreSetting('belloff')
		endif
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

	function! GetSelectionText()
		let [lnum1, col1] = getpos("'<")[1:2]
		let [lnum2, col2] = getpos("'>")[1:2]
		let lines = getline(lnum1, lnum2)
		let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
		let lines[0] = lines[0][col1 - 1:]
		return join(lines, "\n")
	endfunction

	function! GetRegexFromSelection()
		let txt = escape(GetSelectionText(),'/\')
		let txt = substitute(txt,"\n",'\\n','g')
		let txt = substitute(txt,"\t",'\\t','g')
		return '\V' . txt
	endfunction

	function! SelectionAsRegexToRegister(register)
		" recall selection:
		normal! gv
		call setreg(a:register,GetRegexFromSelection())
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
	" Move to the specified character, or to the last character moved to.
	" If 'v' is passed as a flag, return keystrokes for navigating to char.
	" Otherwise just jump straight there and return nothing.
		let keys=""
		let char=a:character
		let visual=0
		let searchFlags=""
		if match(a:flags,'b') != -1
			let searchFlags = 'b'
		endif
		if match(a:flags,'v') != -1
			let visual=1
			let searchFlags .= 'n'
		endif
		if char == ''
			let char = g:foundLast
		else
			let g:foundLast = a:character
		endif
		call SaveSetting('ignorecase')
		call SaveSetting('smartcase')
		set noignorecase
		set nosmartcase
		if visual==1
			echom "searchFlags: " . searchFlags
			let goHere=searchpos('\V' . char, searchFlags)
			" echom "start: [" . line(".") . ", " . col(".") . "] goal: [" . join(goHere,", ") . "]"
			" if not searching backwards, direction is right on the line, and
			" down the document:
			let hDir = match(searchFlags,"b")!=-1 ? "\<Left>" : "\<Right>"
			let vDir = match(searchFlags,"b")!=-1 ? "\<Up>" : "\<Down>"
			if goHere[0] != 0
				if goHere[0] != line(".")
					" <lineNum>gg jumps to <lineNum> without leaving selection:
					let keys .= goHere[0] . 'gg'
					" 0 goes to the very start of the line:
					let keys .= '0'
					" this goes to the right the needed number of characters:
					let keys .= strlen(matchstr(getline(goHere[0]),'\V\[^'.char.']\+')) . 'l'
				else
					let keys .= repeat(hDir,abs(col(".") - goHere[1]))
				endif
			endif
		else
			call search('\V' . char, 'w'. searchFlags)
		endif
		call RestoreSetting('ignorecase')
		call RestoreSetting('smartcase')
		echom keys
		return keys
	endfunction

	function! JumpToNextMatchingChar(flags)
		let char = matchstr(getline('.'), '\%' . col('.') . 'c.')
		call JumpToChar(char,a:flags)
	endfunction

	" Interactive character-jump function
	function! FindChar(flags)
		let char = nr2char( getchar() )
		return JumpToChar(char,a:flags)
	endfunction

	function! CloseTab()
		if &filetype == 'help'
			quit
			return
		endif
		" since tabdo screws up the current tab-index, we grab it first so we
		" can close the appropriate tab:
		let currentTab = tabpagenr()
		let g:tabCount=0
		tabdo let g:tabCount+=1
		if g:tabCount > 1
			exec currentTab . "tabclose"
		else
			qall
		endif
	endfunction

	function! RepeatMacroOnSelection()
	" inspired by:
	" github.com/stoeffel/.dotfiles/blob/2115ecff195d59db09260fbd31b7261126011b7b/vim/visual-at.vim
		echo "@" . getcmdline()
		let char = nr2char(getchar())
		let start = line("'<")
		let goal = line("'>")
		let its = 0
		while its <= goal - start && line(".") <= goal
		" while the macro's inherent motion (assuming it has any) hasn't
		" pushed us past the target line, and we have not done one iteration
		" for each line, loop:
			let startPos = line(".")
			execute "normal @" . char
			let its = its + 1
			if line(".") == startPos
			" If the macro does not change lines by itself, we do instead, so
			" we don't stay in the loop forever:
				execute "normal \<Down>"
			endif
		endwhile
	endfunction


"---------------------Novel keybindings--------------------:

	" @-key during visual selection repeats the specified macro for each
	" selected line:
	xnoremap @ :<C-u>call RepeatMacroOnSelection()<Return>

	" ctrlAltT tears out current pane and sends to a new tab:
	nnoremap <C-A-t> :call PaneToTab()<Return>

	" ctrlPageup goes to next tab:
	noremap <C-PgUp> gT
	" ctrlPagedown goes to previous tab:
	noremap <C-PgDown> gt
	" ctrlShiftPageup moves current tab toward to an earlier position:
	noremap [5;6~ :-tabmove<Return>
	" ctrlShiftPagedown moves current tab toward to an earlier position:
	noremap [6;6~ :+tabmove<Return>
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
	" ctrlQ either closes the current help-pane or the current tab:
	nnoremap <C-q> :call CloseTab()<Return>
	" ctrlAltQ attempts to quit vim:
	nnoremap <C-A-q> :qa<Return>
	" ctrlX deletes current line:
	nnoremap <C-x> Vx
	inoremap <C-x> <C-o>Vx
	" ctrlAltX deletes all lines:
	noremap <silent> <C-A-x> :call SelectAllThenDo("normal x")<Return>
	" 2: ctrlS saves current file:
	vnoremap <C-s> <Esc>:w<Return>
	inoremap <C-S> <Esc>:w<Return>i<Right>
	nnoremap <C-s> :w <Return>
	" ^ Note that many shell-clients bind ctrlS to send the freeze-output
	" signal (XOFF). This command won't work if that's not done. In most cases
	" it can be disabled from .bashrc

	" altS clears trailing whitespace if present then places a semicolon at EOL:
	nnoremap <silent> <A-s> :call InsertAtEOL(';',1)<Return>
	" alt-0 clears trailing whitespace if present then places ')' at EOL:
	nnoremap <silent> <A-)> :call InsertAtEOL(')',1)<Return>
	" shift8/openParen surrounds current selection in parentheses from visual mode:
	vnoremap <silent> ( <Esc>`<i(<Esc>`><Right>a)<Esc>
	" shift9/closeParen does the same as above:
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
	" ctrlR starts a replace-command containing the selected text:
	vnoremap <C-r> :call SelectionAsRegexToRegister('h')<Return>:<BS><BS><BS><BS><BS>%s/<C-r>h//<Left>
	" :credit http://stackoverflow.com/questions/676600/
	" shiftR in visual mode starts a replace-command on the selected text
	" (set up to only affect text until the end of the line):
	vnoremap R :call SelectionAsRegexToRegister('h')<Return>:<BS><BS><BS><BS><BS>s/\%><C-r>=col('.')<Return>c<C-r>h//<Left>
	" shiftR in normal mode replaces from current cursor position until EOL:
	nnoremap R :s/\%><C-r>=col('.')<Return>c//<Left><Left>
	" :credit https://www.reddit.com/r/vim/comments/5zbyfw/tn/dewvpfw/
	" enter-key copies in visual mode:
	vmap <Return> y

	" 2: f-key finds the next single character (accepted afterwards
	" interactively) on multiple lines, rather than just the current one:
	nnoremap <silent> f :call FindChar('')<Return>
	vnoremap <silent> <expr> f FindChar('v')
	" 2: shiftF finds previous single character (accepted afterwards
	" interactively):
	nnoremap <silent> F :call FindChar('b')<Return>
	vnoremap <silent> <expr> F FindChar('vb')
	" 2: semicolon-key repeats previous FindChar search:
	nnoremap <silent> ; :call JumpToChar('','')<Return>
	vnoremap <silent> <expr> ; JumpToChar('','v')
	" 2: comma-key repeats previous FindChar search backwards:
	nnoremap <silent> , :call JumpToChar('','b')<Return>
	vnoremap <silent> <expr> , JumpToChar('','vb')

"-------------------Keybinding overrides-------------------:

"-- Emmet bindings:
	" altZ expands tags instead of Emmet's default two-step shortcut ctrlY-then-,
	imap <A-z> <C-Y>,

"-- Navigation bindings:

	" 6: home-key goes to the beginning of the virtual line, and toggles
	" between soft home and hard home after that:
	nnoremap <expr> <Home> SmartHome('n')
	nnoremap <expr> <kHome> SmartHome('n')
	imap <expr> <Home> "\<C-o>" . SmartHome('i')
	imap <expr> <kHome> "\<C-o>" . SmartHome('i')
	vnoremap <expr> <Home> SmartHome(visualmode())
	vnoremap <expr> <kHome> SmartHome(visualmode())

	" 6: end-key goes to the end of the virtual line or the actual end if
	" already there:
	nnoremap <silent> <expr> <End> SmartEnd('n')
	nnoremap <silent> <expr> <kEnd> SmartEnd('n')
	inoremap <silent> <expr> <End> "\<C-o>" . SmartEnd('i')
	inoremap <silent> <expr> <kEnd> "\<C-o>" . SmartEnd('i')
	vnoremap <silent> <expr> <End> SmartEnd(visualmode())
	vnoremap <silent> <expr> <kEnd> SmartEnd(visualmode())

	"2: o-key and shiftO insert a line below or above the current one (without staying in insert mode)
	" the x below deletes the autoindent whitespace 2:
	nmap <silent> <expr> o InsertLineBelow() . "\<Esc>"
	nmap <silent> <expr> O InsertLineAbove() . "\<Esc><C-Del>"

	" 6: up-key goes up by virutal line
	" down-key goes down by virutal line
	nnoremap <Up> gk
	nnoremap <Down> gj
	vnoremap <Up> gk
	vnoremap <Down> gj
	inoremap <Up> <C-o>gk
	inoremap <Down> <C-o>gj


	" s-key does not yank, just deletes then enters insert-mode:
	vnoremap <expr> s SmartS()
	nnoremap <expr> s SmartS()
	" x-key does not yank, just deletes:
	vnoremap <expr> x SmartX()
	" p-key and shiftP do not yank, just delete:
	vnoremap <expr> p SmartX() . 'p'
	vnoremap <expr> P SmartX() . 'p'


	" shiftU redoes:
	noremap U <C-r>
	" insert-key enters replace-mode
	nnoremap <Insert> i<Insert>

	" shiftU capitalizes SQL keywords:
	vnoremap <silent> <C-u> :call ChangeSqlCase() <Return><Return>
 	" U-key capitalizes any alphas in selection:
	vnoremap <silent> U gU
	" u-key lowercases any alphas in selection:
	vnoremap <silent> u gu


"-- Selection stuff

	" 2: shiftHome and shiftEnd select from current position to whatever
	" positions these are happed to jump to:
	nmap <S-Home> v<Home>
	nmap <S-End> v<End>

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
	" shiftI begins insert above:
	nmap <silent> <expr> <S-i> InsertLineAbove()
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
