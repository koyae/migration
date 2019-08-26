" Strip trailing whitespace on save:
augroup striptrailing
	autocmd!
	autocmd BufWritePre * :%s/\s\+$//e
augroup END

" Custom handling by filetype:
augroup oddboyz
	autocmd!
	autocmd BufNewFile,BufRead, pom.xml,web.xml,*.yaml,*.ansible* set tabstop=2 expandtab shiftwidth=2
augroup END

augroup ansible
	autocmd BufNewFile,BufRead, *.ansible* setf yaml.ansible
augroup END

augroup gitconfigs
	autocmd!
	autocmd BufNewFile,BufRead, .gitconfig* setf gitconfig
augroup END

augroup screenstuff
	autocmd!
	autocmd BufNewFile,BufRead, *.screen,.screenrc* setf screen
augroup END

" allow various comments to rewrap correctly:
augroup vimstuff
	autocmd!
	autocmd BufNewFile,BufRead, *.vim,.vimrc set comments+=:\\\\|
	" ^ allow line-extension character
augroup END

augroup pgstuff
	autocmd!
	autocmd BufNewFile,BufRead, *.postgre.sql,scp://*.postgre.sql setf pgsql
		\| set comments=:--
augroup END

" Conventions:

" Conventions: marks and registers
"
" Sophisticated macros may naturally require storage of clipboard or
" cursor-location info, but perfect data-hiding is impractical, as it would
" require making a function-call in every macro. So instead, I'll lay out some
" conventions for how to store data:
"
" register 's': used to temporarily hold the contents of the default register '"'
" in some cases this is unavoidable because of `diw` and similar
"
" Otherwise, register 'p' is used instead of the default register to avoid
" overwriting it in the first place. This should theoretically be used more
" often than register 's'.
"
" mark '`' is used to temporarily store the last cursor position in macros
" mark 'w' is an alternate for the same purpose
" mark 'u' is a secondary alternate for the same purpose

" Conventions: character-representations
"
" I won't explain the full spec here but here are some expamples of how
" plain-english macro explanations should look (the ones chosen are nonsense so
" they don't turn up when I'm searching for my real boys):
"
" 	" one-key deletes everything in the buffer:
" 	nnoremap 1 GVggx
"
" 	" F1-key starts help-search:
" 	nnoremap <F1> :h
" 	imap <F1> <C-o><F1>
"
" 	" one-then-two deletes everything in the buffer, saves, and quits:
" 	nnoremap 21 GVggx:wq<Return>
"
" 	" ctrlW-then-shiftW is the same as undo:
" 	nnoremap <C-w>W u
"
" The following characters might have ambiguous names so here's what I'll use
" when describing macros:
"
" 	{ openbrace
" 	} closebrace
" 	( openparen
" 	) closeparen
" 	" quote
" 	' apostrophe
" 	< lessThan
" 	> greaterThan
" 	1 one
" 	2 two
" 	3 three
" 	4 four
" 	5 five
" 	6 six
" 	7 seven
" 	8 eight
" 	9 nine
" 	0 zero

"--------------------Compatibility settings----------------:
	:set nocompatible
	:set <S-Left>=[D
	:set <S-Right>=[C
	:set <C-Left>=OD
	:set <C-Right>=OC
	:set <A-a>=a
	:set <A-b>=b
	:set <A-c>=c
	:set <A-d>=d
	:set <A-f>=f
	:set <A-e>=e
	:set <A-g>=g
	:set <A-o>=o
	:set <A-p>=p
	:set <A-q>=q
	:set <A-r>=r
	:set <A-s>=s
	:set <A-=>==
	:set <A-x>=x
	:set <A-z>=z
	:set <A-(>=9
	:set <A-)>=0
	:set <C-A-x>=
	:set <C-A-t>=
	:set <C-A-q>=
	:set <A-1>=1
	:set <A-i>=i
	:set <C-S-g>=
	:set <C-J>=
	:set ttimeout
	:set ttimeoutlen=100
	" ^ 2: This prevents the above key-codes from being easily confused by Esc
	" being pressed followed promptly (but not instantaneously) by another
	" key; without this setting leaving insert mode by pressing Esc followed
	" promptly (though perhaps not instantaneously) by a keystroke meant to be
	" received by normal mode can cause strange characters or other weird
	" nonsense to be processed

	let term=$TERM
	if term == 'screen' || term == "screen-256color" || term == "xterm-256color"
	" if running from `screen`, assume xterm-signals:
		:set term=xterm
	endif

"--------------------Plugin Imports------------------------:
	filetype plugin on
	source ~/.vim/plugin/cmdalias.vim
	" grab everything from ~/.vim/bundle:
	execute pathogen#infect()
	runtime macros/matchit.vim " allow jumping to matching XML tags using '%'

" -- Ultisnips config:
	" altQ expands snippet:
	let g:UltiSnipsExpandTrigger="<A-q>"
	" tab-key moves to next tabstop while snippets are active:
	let g:UltiSnipsJumpForwardTrigger="<tab>"
	" shiftTab moves to previous tabstop while snippets are active:
	let g:UltiSnipsJumpBackwardTrigger="[Z"
	let g:UltiSnipsEditSplit="vertical"

" -- Netrw config:
	let g:netrw_banner=0
	" make netrw splits happen to the right (doesn't work with preview-splits,
	" even if they're set vertical :C):
	" let g:netrw_altv=1

"---------------------User settings------------------------:

"-- Display
	colorscheme koyae
	" 4: Only turn on syntax highlighting once; this avoids turning
	" highlighting off when viewing/editing an unrecognized filetype for which
	" the user has already manually performed `set syntax=<syntax>` or `set
	" filetype=<filetype>`:
	let g:koyaeSyntaxEnabled = 1
	if !exists('g:koyaeSyntaxEnabled')
		syntax enable
	endif " :4
	let g:is_posix=1 " this will be right on 99% of systems
	if exists('+breakindent')
		:set breakindent
		" ^ paragraphs moved all the way over if there's an indent in front
		" (long line soft wrap)
	endif
	:set linebreak " whole-word wrapping instead of mid-word

"-- I/O
	:set bs=2
	:set mouse=n
	:set scrolloff=0
	:set noincsearch " no incremental search; makes me think i hit enter already
	:set ttymouse=sgr
	:set gdefault " find-and-replace defaults to global rather than just current line
	:set autoindent " keep the current indentation on new <CR>. Negate with :setlocal noautoindent
	:set splitright " make :vs open on right instead of bumping current pane over
	:set splitbelow " make :split open files on the bottom instead of bumping current pane down
	:set tabstop=4 " make tab-characters display as 4 spaces instead of default 8
	:set shiftwidth=0 " make '>' (angle bracket) always just match `tabstop`
	:set ignorecase smartcase "searching is non-case-sensitive unless there's a cap
	:set shellcmdflag=-c
	" :set ttimeout

"-- Formatting behavior:
	:set formatoptions+=j " allow vim's re-wrapping functionality to join as well as split
	:set formatoptions-=r " don't repeat the single-line comment symbol when pressing enter

"-- cmdalias.vim aliases:
	:Alias Wq wq
	:Alias WQ wq
	:Alias qw wq
	:Alias Q q
	:Alias w W

"-- Custom commands:
	:command! -nargs=? W call RobustSave(<f-args>)
	:command! Reup source ~/.vimrc
	:Alias reup Reup
	" Create a new tab with the desired help-page inside of it:
	:command! -nargs=1 Tabh :tabnew | :h <args> | normal! <C-w><Up>:q<Return>
	:Alias tabh Tabh
	:command! -nargs=+ Resize :call Resize(<f-args>)
	:command! Hoh set hlsearch
	:Alias hoh Hoh
	" Count the number of commas on the current line:
	:command! Comman keeppattern s/,//n

	:command! -range=% Imply <line1>,<line2>s/^./>\0/ | noh

"-------------------Functions------------------------------:

" I use the convention "before" in function names to connote one character before
" In turn "after" means the opposite.
" To connote the LINE before the cursor's current position, I use "above".
" In turn "below" means the opposite.

" Note `function!` forces overwrite if necessary on creation of a funciton


	" RobustSave([targetPath])
	" A (somewhat) robust wrapper for :W and :sav that avoids
	" https://github.com/vim/vim/issues/1268 if SCP-paths contain spaces
	function! RobustSave(...)
		let path = expand('%')
		if a:0 == 1
			let path = a:1
		endif
		if ( match(path, "scp://") == 0 )
		" ^ if the remote filename might cause problems with how netrw tries to
		" invoke scp, correct before saving:
			let tmpfile = exists('b:netrw_tmpfile') ?
				\ escape(b:netrw_tmpfile,' ')
				\ : escape(tempname(),' ')
			execute "write! " . tmpfile
			set nomod
			let l:doMe='AsyncRun'
				\ . ' -post=call\ delete(''' . tmpfile . ''')'
				\ . '\ |\ echo\ "delayed\ write"\ g:asyncrun_status\ strftime(''\%X'') '
				\ . "scp " . tmpfile
				\ . " " . escape(expand('%'),' ')
			" ^ inspired by:
			" github.com/skywind3000/asyncrun.vim/wiki/Get-netrw-using-asyncrun-to-save-remote-files
			" echom l:doMe
			execute doMe
		else
		" otherwise, just write as normal:
			execute "sav " . escape(path, ' ')
		endif
	endfunction

	function! Resize(first,...)
		" echom type(a:first)
		if a:0 == 0
			" echom 'a'
			execute "resize " . string(a:first)
		elseif a:first == "-v"
			echom 'b'
			" resize a:1
		elseif a:1 == "-v"
			echom 'c'
			" resize a:first
		elseif a:first == "-h"
			echom 'd'
			" vertical resize a:1
		elseif a:1 == "-h"
			echom 'e'
			" vertical resize a:first
		else
			echom "Resize(): Huh?"
		endif
	endfunction

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

	" GetCharFromCursor([offset])
	function! GetCharFromCursor(...)
		let offset = a:0 >= 1 ? a:1 : 0
		return matchstr(getline('.'),'\%' . (col('.') + offset) . 'c.')
	endfunction

	function! InsertLineBelow()
		return "m`i\<C-o>$\<CR>"
	endfunction

	function! InsertLineAbove()
		" if matchstr(getline('.'),'\(\_^\s\+\)\@<=\S')
		" let indentAmount = GetCurrentIndentLevel()
		let colpos=virtcol('.')
		return "i\<End>\<Home>\<CR>\<C-o>" . (l:colpos + 1) . '|'
	endfunction

	" SetEncloseWithFunctionCallFunctionName([returnThis])
	" Set the name of a function so that other macros/functions can access it
	" and know what function to wrap things with when instructed.
	"
	" Using the optional argument for this function allows a string of the
	" caller's choice to be returned which can be useful in <expr> bindings,
	" such that actions are executed only after the user has responded to the
	" input-prompt.
	"
	function! SetEncloseWithFunctionCallFunctionName(...)
		let returnThis = a:0 >= 1 ? a:1 : ''
		let g:EncloseWithFunctionCallFunctionName = input("Function name? ")
		return returnThis
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

	" PgCap([keywordType])
	" 	return keystrokes if given keywordType or keyword under cursor should
	" 	be capitalized. If keywordType is omitted, use the keyword type of
	" 	whatever character is under the cursor.
	"
	" 	PgCap(lineNumber, columnNumber) -> return keystrokes to capitalize
	" 	the character under the cursor if it is a Postgres keyword.
	" 	(Currently only works from normal mode.)
	"
	" The easiest way to use this function for the moment is with the
	" following invocation, starting with the cursor on the first line on
	" which capitalization should start. The first argument should be the last
	" line on which capitalization should be performed.
	"
	" :exec 'silent! normal! ' . To('$','$','.',1,'',":call PgCap()\<Enter>")
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
		if index(['pgsqlKeyword','pgsqlOperator','pgsqlType','pgsqlVariable'],l:kwType) >= 0
			normal! vgU
		endif
	endfunction

	" To(toLine,toColumn[,fromLine='.'[,luddite=false,lineInject='',colInject='']])
	" Return the keystrokes for moving the cursor to the specified line+column
	"
	" toLine      --  specific line-number or symbol like '$'
	"
	" toColumn    --  desired final column-number or symbol like '$' or '^'
	"
	" luddite     --  boolean telling function whether to move through each
	" column before reaching the desired position instead of using vim's
	" goto-line and goto-column jumps. Hitting each character in turn is
	" necessary for some macros to work
	"
	" lineInject  --  perform this action on every line traversed through.
	" Only works in luddite mode.
	"
	" colInject   --  perform this action on every character
	"
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
					let rString .= l:colInject
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
			let rString = ''
			let difference = l:toCol - l:fromCol
"			echom 'difference: ' . l:difference
			for c in range(l:fromCol,l:toCol,1 - 2*(l:difference<0))
				let rString	.= l:inject . c . '|'
			endfor
			return l:rString
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
" SmartEnter
	function! SmartReturn()
		"let indentLevel = GetCurrentIndentLevel()
		let terminalChar = matchstr( getline('.'),'\%' . col('.') . 'c.' )
		let pushTheseDown = ['(',')','{','}','[',']']
		if AtEndOfLine() && index(pushTheseDown,terminalChar)==-1
			return "a\<CR>\<Space>\<Esc>"
		endif
		return "i\<CR>\<Esc>^"
	endfunction

" nnoremaped to <Del>
	function! SmartDelete()
		" If we're deleting from the end of the current line, immediately eat
		" any whitespace that's at the beginning of the next line, since this
		" is pretty much universally unwanted for pulling stuff from below
		" lines onto current:
		if AtEndOfLine()
			return "j:s/^\\s\\+//e | noh\<Return>0i\<BS>\<C-o>mp\<Esc>`p"
		else
			return '"_x'
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

	" Return the user's current selection as a string
	" GetCurrentSelection
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

	function! RelimitRegister(regSymbol,limitChar,stripClass)
		return Relimit(getreg(a:regSymbol),a:limitChar,a:stripClass)
	endfunction

	function! Relimit(string,limitChars,stripClass)
		let endMap = {
			\ '(': ')',
			\ '{': '}',
			\ '[': ']',
			\ '<': '>'
		\ }
		let startCharsReversed = split(a:limitChars, '\zs')
		call reverse(startCharsReversed)
		let startCharsReversed =
			\ map(startCharsReversed,'get(endMap,v:val,v:val)')
		let selText = a:string
		let selText = substitute(selText, '^' . a:stripClass, '', '')
		let selText = substitute(selText, a:stripClass . '$', '', '')
		let selText = a:limitChars . selText . join(startCharsReversed,'')
		return selText
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
		" echom keys
		return keys
	endfunction

	function! JumpToNextMatchingChar(flags)
		let char = matchstr(getline('.'), '\%' . col('.') . 'c.')
		return JumpToChar(char,a:flags)
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
		" since `tabdo` screws up the current tab-index, we grab it first so
		" we can close the appropriate tab:
		let currentTab = tabpagenr()
		let tabCount = tabpagenr("$")
		if tabCount > 1
			if currentTab > 1 && currentTab < tabCount
			" if current tab is neither the first tab nor the last:
				exec currentTab . "tabclose"
				tabprev
			else
				exec currentTab . "tabclose"
			endif
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

	" AppendToFile(text[,fifoPath])
	" Append the current selection or given text to a specified file.
	"
	" The primary intent of this file is to allow writing to fifo-files which
	" are being read within a continuous loop by one or more outside
	" utilities, to allow code-snippets to be executed from vim without
	" changing windows/panes.
	"
	" #PipeToFile
	"
	function! AppendToFile(...)
		" First, we define a dictionary of suffixes (with vim &syntax values
		" as keys) to allow lookup of an appropriate statement/call to place
		" at the end of the file. This line should print a statement to make
		" it clear that the process watching the FIFO-file for commands to
		" execute has completed all of them, since it may be hard to tell
		" otherwise whether it's frozen, still working, or done
		let suffdict = {
			\ 'pgsql': "\n;SELECT '(vim) All done (vim)';"
		\ }
		let suffdict.sql = suffdict.pgsql
		let text = a:0 >= 1 ? a:1 : GetSelectionText()
		let fifoPath = a:0 >= 2 ? a:2 : '/tmp/fif'
		" Below, first backslash prevents vim from expandeding '%' to current
		" filename and the second backslash allows the '\n' to actually reach
		" `printf`:
		" echom
		call writefile(
			\ split( text . get(suffdict,&syntax,''), "\n", 1 ),
			\ fifoPath
		\ )
		" ^ vim.1045645.n5.nabble.com/Write-register-contents-to-file-tp5610081p5610229.html
	endfunction

	" PipeToSocket(text[,socketPath])
	" Write the current selection to the socket at the given path.
	"
	" This can be useful in the case that an application is listening for
	" input on a given socket but you don't want/need to leave vim to
	" communicate with it. Having a process listen to a socket in place of
	" stdin can be initialized like:
	" 	`socat UNIX-LISTEN:/tmp/sock STDOUT | psql <connectionOptions>`
	" After that you can pipe stuff to this socket using socat, and it will be
	" read by whatever application you piped into before (psql, in the above
	" example). You can even have another terminal window (or pane) open which
	" displays the results there. This allows you to see the output even if
	" you're not touching the console directly.
	" More info can be found at: https://unix.stackexchange.com/a/384162/153690
	function! PipeToSocket(...)
		let text = a:0 >= 1 ? a:1 : GetSelectionText()
		let socketPath = a:0 >= 2 ? a:2 : '/tmp/sock'
		let text = printf(
			\ 'printf %s %s | socat STDIN UNIX-CONNECT:%s',
			\ shellescape('%s\n'),
			\ shellescape(text),
			\ shellescape(socketPath)
		\ )
		call system(text)
	endfunction

	function! PipeToSocketTest(...)
		let socketPath = a:0
		call PipeToSocket('SELECT 1;',socketPath)
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
	noremap [5;6~ :tabmove -1<Return>
	" ctrlShiftPagedown moves current tab toward to an earlier position:
	noremap [6;6~ :tabmove +1<Return>
	" altUp swaps current line(s) with above, keeping selection if needed:
	vnoremap <A-Up> <Esc>`<V`>d<Up>P`[V`]
	nnoremap <A-Up> dd<Up>P
	imap <A-Up> <C-o>:execute "normal \<lt>A-Up>"<Return>
	" altDown swaps current line(s) with below, keeping selection if needed:
	vnoremap <A-Down> <Esc>`<V`>d<End>p`[V`]
	nnoremap <A-Down> ddp
	imap <A-Down> <C-o>:execute "normal \<lt>A-Down>"<Return>
	" ctrlUp scrolls screen up one line without moving cursor:
	noremap <C-Up> <C-y>
	inoremap <C-Up> <C-o><C-y>
	" ctrlDown scrolls screen down one line without moving cursor:
	noremap <C-Down> <C-e>
	inoremap <C-Down> <C-o><C-e>
	" ctrlQ either closes the current help-pane or the current tab:
	nnoremap <C-q> :call CloseTab()<Return>
	" ctrlAltQ attempts to quit vim:
	nnoremap <C-A-q> :qa<Return>
	" altX deletes the last character on the current line:
	nmap <A-x> m`$x``
	imap <A-x> <C-o>m`<C-o>$<Backspace><C-o>``

	" ctrlX deletes the current line (without overwriting clipboard register)
	nnoremap <C-x> V"_x
	imap <C-x> <C-o><C-x>
	vmap <C-x> x
	" ctrlAltX deletes all lines:
	noremap <silent> <C-A-x> :call SelectAllThenDo("normal x")<Return>
	" 2: ctrlS saves current file:
	vnoremap <C-s> <Esc>:call RobustSave()<Return>
	inoremap <C-s> <C-o>:call RobustSave()<Return>
	nnoremap <C-s> :call RobustSave()<Return>
	" ^ Note that many shell-clients bind ctrlS to send the freeze-output
	" signal (XOFF). This command won't work if that's not done. In most cases
	" it can be disabled from .bashrc

	" 2: altR removes the function-call currently under the cursor
	nmap <A-r> :normal viwxm`%x``x<Return>
	imap <A-r> <C-o><A-r>
	" 2: ctrlE sets enclosure function and encloses the current word or
	" selection with a function-call:

	nnoremap <C-e> :call SetEncloseWithFunctionCallFunctionName()<Return>
	imap <C-e> <C-o><C-e>
	" 4: altE encloses the current word or selection with a function-call:
	nmap <A-e> :let @p=g:EncloseWithFunctionCallFunctionName
		\ \| normal viw(%"pP`[<Return>
	imap <A-e> <C-o><A-e>
	vmap <expr> <C-e> SetEncloseWithFunctionCallFunctionName("\<A-e>")
	vmap <A-e> <A-g>let @p=g:EncloseWithFunctionCallFunctionName<Return>gv(%"pP
	" ^ set register, restore selection, jump to matching parenthesis, paste

	" altS clears trailing whitespace if present then places a colon at EOL:
	nnoremap <silent> <A-c> :call InsertAtEOL(':',1)<Return>
	inoremap <silent> <A-c> <C-o>:call InsertAtEOL(':',1)<Return>
	" altS clears trailing whitespace if present then places a semicolon at EOL:
	nnoremap <silent> <A-s> :call InsertAtEOL(';',1)<Return>
	inoremap <silent> <A-s> <C-o>:call InsertAtEOL(';',1)<Return><Right>
	" alt0 clears trailing whitespace if present then places ')' at EOL:
	nnoremap <silent> <A-)> :call InsertAtEOL(')',1)<Return>
	imap <A-)> <C-o>mo<C-o><A-)><C-o>`o
	" alt1 clears trailing whitespace if present then places a comma at EOL:
	nnoremap <silent> <A-1> :call InsertAtEOL(',',1)<Return>
	imap <silent> <A-1> <C-o><A-1><Right>
	" altP clears trailing whitespace if present then pastes at EOL, then
	" jumps to start of paste:
	nnoremap <silent> <A-p> :call InsertAtEOL('',1)<Return>$a <Esc>p`[
	" openparen surrounds current selection in parentheses from visual mode:
	vnoremap <silent> ( <Esc>`<i(<Esc>`>a<Right>)<Esc>
	" closeparen does the same as above:
	vnoremap <silent> ) <Esc>`<i(<Esc>`>a<Right>)<Esc>
	" quote-then-openbrace wraps selection in braces:
	vnoremap "{ <Esc>`<i{<Esc>`>a<Right>}<Esc>
	" quote-then-closebrace wraps selection in braces:
	vnoremap "} <Esc>`<i{<Esc>`>a<Right>}<Esc>
	" quote-openbracket wraps selection in brackets:
	vnoremap "[ <Esc>`<i[<Esc>`>a<Right>]<Esc>
	" quote-closebracket wraps selection in brackets:
	vnoremap "] <Esc>`<i[<Esc>`>a<Right>]<Esc>
	" [quote-quote]
	" "example text" "xxx" "non-target text"
	" quote-then-quote mode surrounds selection in quotes:
	vnoremap "" "pygv"=RelimitRegister('p','"',"'")<Return>P
	" quote-then-singleQuote from Visual mode "encloses" selection in quotes:
	vnoremap "' "pygv"=RelimitRegister('p',"'",'"')<Return>P
	" [dollar-dollar] [dolla-dolla]
	" quote-then-dollarsign-then-dollarsign from Visual mode encloses selection
	" in '$$':
	vnoremap "$$ "pygv"=RelimitRegister('p',"$$","'")<Return>P
	" quote-then-backtick from Visual mode surrounds selection in backticks:
	vnoremap "` "pygv"=RelimitRegister('p',"`",'')<Return>P
	vnoremap "`<Return> "pygv"=RelimitRegister('p',"`",'')<Return>P
	vnoremap "`" "pygv"=RelimitRegister('p','`"','')<Return>P
	" quote-then-lessThan from Visual mode surrounds selection in
	" angle-brackets:
	vnoremap "< "pygv"=RelimitRegister('p','<','')<Return>P
	" quote-then-greaterThan from Visual mode surrounds selection in
	" angle-brackets:
	vnoremap "> "pygv"=RelimitRegister('p','<','')<Return>P

	" quote-then-star surrounds selection in asterisks:
	vnoremap "* "pygv"=RelimitRegister('p','*','')<Return>P
	vnoremap "*<Return> "pygv"=RelimitRegister('p','*','')<Return>P
	" quote-
	vnoremap "** "pygv"=RelimitRegister('p','**','')<Return>P

	" shiftTab reduces indent
	nnoremap <S-Tab> <<Left>
	vnoremap <S-Tab> <gv
	imap <S-Tab> <C-o><S-Tab>
	nnoremap <Tab> ><Right>

	" altB groups a selected set of arguments spread across multiple lines onto
	" one line:
	vnoremap <A-b> :s/,\n\s*/, /<Return>

	" altEquals adds a space after (sequences of) '>' which begin a line:
	vmap <A-=> :sm/^\(>\+\)\([^ >]\)/\1 \2/ <Return>:noh <Return>
	nmap <A-=> :%sm/^\(>\+\)\([^ >]\)/\1 \2/ <Return>:noh <Return>

	" D-key-then-minus decrements the nearest integer at/after the cursor:
	nnoremap d- <C-x>
	" D-key-then-plus increments the nearest integer at/after the cursor:
	nnoremap d+ <C-a>

"-------------------Keybinding overrides-------------------:

"-- Emmet bindings:
	" altZ expands tags instead of Emmet's default ctrlY-then-comma:
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
	nmap <silent> <expr> <A-o> InsertLineBelow() . "\<Esc>``"
	nmap <silent> <expr> o InsertLineBelow() . "\<Esc>"
	nmap <silent> <expr> O InsertLineAbove() . "\<Esc>"

	" backslash-key inserts a backslash:
	nmap <silent> <expr> \ ToInsertBeforeCurrentChar('\')
	" space inserts a space in front of current character:
	noremap <silent> <expr> <Space> ToInsertBeforeCurrentChar(" ")

	" h-key goes up one line:
	nnoremap h j
	" l-key goes down one line:
	nnoremap l k

	" equals-key helps to navigate to lower lines (avoids shift):
	nnoremap = +
	vnoremap = +

	" shiftEquals gets swapped with standard plus-key functionality:
	nnoremap + =
	vnoremap + =

	" 6: up-key goes up by virutal line
	" down-key goes down by virutal line
	nnoremap <Up> gk
	nnoremap <Down> gj
	vnoremap <Up> gk
	vnoremap <Down> gj
	inoremap <Up> <C-o>gk
	inoremap <Down> <C-o>gj

	" g-then-i goes to the next matching indent:
	nnoremap gi :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%>' . line('.') . 'l\S', 'e')<Return>
	" g-then-shiftI goes to the previous matching indent:
	nnoremap gI :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%<' . line('.') . 'l\S', 'be')<Return>

	" allow shiftLeft to stay held while selecting without jumping by word
	vmap <S-Left> <Left>
	" allow shiftRight to stay held while selecting without jumping by word
	vmap <S-Right> <Right>
	" allow shiftDown to stay held while selecting without jumping by screen
	vmap <S-Down> <Down>
	" allow shiftUp to stay held while selecting without jumping by screen
	vmap <S-Up> <Up>
	" ctrlRight keeps the cursor on the right side of words when jumping:
	nnoremap <C-Right> e
	nnoremap <C-Left> b
	" ctrlRight jumps by word like in most text editors:
	vnoremap <C-Right> e
	" ctrlLeft jumps by word like in most text editors:
	vnoremap <C-Left> b
	":4 sadly the previous two aliases do not quite work in PuTTY
	inoremap <C-Right> <C-o>e
	inoremap <C-Left> <C-o>b

	" 2: j-key jumps to the next/previous character which matches the one under
	" the cursor:
	nnoremap <silent> j :call JumpToNextMatchingChar('')<Return>
	vnoremap <silent> J :<C-u>let @p=escape(GetCharFromCursor(),'/$\') \| set nohlsearch<Return>gv?\V<C-r>p<Return>
	" 2: shiftJ does the same only backwards:
	nnoremap <silent> J :call JumpToNextMatchingChar('b')<Return>
	vnoremap <silent> j :<C-u>let @p=escape(GetCharFromCursor(),'/$\') \| set nohlsearch<Return>gv/\V<C-r>p<Return>

"-- Editing bindings:

	vnoremap : :s/

	" enter-key acts like enter:
	nmap <silent> <expr> <Return> SmartReturn()
	"inoremap <silent> <expr> <Return> SmartReturn()
	" shiftI begins insert above:
	" TODO: clone indent from line above or current line depending on which
	" one(s) are blank
	nmap <expr> <S-i> line('.')==1 ? "Oi" : "\<Up>k"
	" k-key begins insert below:
	nmap <silent> <expr> k InsertLineBelow()
	"<A-i> i\<End>\<End>\<CR>
	" backspace-key deletes one character back
	nmap <BS> i<BS><Esc><Right>
	" delete-key acts like x unless at end of line
	noremap <silent> <expr> <Del> SmartDelete()
	nnoremap <silent> <expr> x SmartX()
	" ctrlDelete deletes rest of line
	nmap <C-kDel> v<S-$><Left>x

	" ctrlBackspace deletes previous word:
	nmap  i<C-w><Esc>x

	" altD eats next word / deletes next word:
	nnoremap <silent> <A-d> :call EatNextWord() <Return>
	inoremap <silent> <A-d> <Right><Esc>:call EatNextWord() <Return>i

	" s-key does not yank, just deletes then enters insert-mode:
	vnoremap <expr> s SmartS()
	nnoremap <expr> s SmartS()
	" x-key does not yank, just deletes:
	vnoremap <expr> x SmartX()
	" shiftX does not yank, just deletes:
	nmap X <Left>x
	" p-key and shiftP do not yank, just paste:
	vnoremap <expr> p SmartX() . 'P'
	vnoremap <expr> P SmartX() . 'P'

	" shiftU redoes:
	noremap U <C-r>
	" insert-key enters replace-mode
	nnoremap <Insert> i<Insert>

	" shiftU capitalizes SQL keywords:
	nnoremap <silent> <C-u> :exec 'silent! normal! ' . To('$','$','.',1,'',":call PgCap() \<Enter>")
	" U-key capitalizes any alphas in selection:
	vnoremap <silent> U gU
	" u-key lowercases any alphas in selection:
	vnoremap <silent> u gu

"--- Find and replace stuff

	" ctrlF opens search-mode:
	nnoremap <C-f> /
	vnoremap <C-f> "fy/\V<C-r>f
	" hash-key and star-key (asterisk-key) search on current selection as a token:
	" TODO: we'll need to actually escape the clipboard-contents instead of
	" using \V, since \V disables use of \< and \>
	vnoremap * "fy/\V\<<C-r>f\><Return>
	vmap # "fy?\V\<<C-r>f\><Return>
	" ctrlG searches on current selection (if present, otherwise repeats last)
	nnoremap <C-g> n
	vmap <C-g> <C-f><Return>
	" ctrlShiftG searches backward on current selection (if present, otherwise repeats last)
	nnoremap <C-S-g> N
	vnoremap <C-S-g> "fy?\V<C-r>f<Return>
	" normal ctrlH starts a document-wide replace:
	nnoremap <C-h> :%s/
	" visual ctrlH starts replacement within selection:
	vnoremap <C-h>  :s/
	" ctrlR starts a replace-command containing the selected text:
	vnoremap <C-r> :call SelectionAsRegexToRegister('h')<Return>:<BS><BS><BS><BS><BS>%s/<C-r>h//<Left>
	" :credit http://stackoverflow.com/questions/676600/
	" shiftR in visual mode starts a replace-command on the selected text
	" (set up to only affect text until the end of the line):
	vnoremap R :call SelectionAsRegexToRegister('h')<Return>:<BS><BS><BS><BS><BS>s/\%><C-r>=col('.')-1<Return>c<C-r>h//<Left>
	" shiftR in normal mode replaces from current cursor position until EOL:
	nnoremap R :s/\%><C-r>=col('.')<Return>c//<Left><Left>
	" :credit https://www.reddit.com/r/vim/comments/5zbyfw/tn/dewvpfw/
	" enter-key copies in visual mode:
	vmap <Return> y
	" qq dismisses search-highlighting:
	nnoremap qq :noh<Return>

	" 2: f-key finds the next single character (accepted afterwards
	" interactively) on multiple lines, rather than just the current one:
	nnoremap <silent> f m`:call FindChar('')<Return>
	vnoremap <silent> <expr> f 'm`' . FindChar('v')
	" 2: shiftF finds previous single character (accepted afterwards
	" interactively):
	nnoremap <silent> F m`:call FindChar('b')<Return>
	vnoremap <silent> <expr> F 'm`' . FindChar('vb')
	" 2: semicolon-key repeats previous FindChar search:
	nnoremap <silent> ; :call JumpToChar('','')<Return>
	vnoremap <silent> <expr> ; JumpToChar('','v')
	" 2: comma-key repeats previous FindChar search backwards:
	nnoremap <silent> , :call JumpToChar('','b')<Return>
	vnoremap <silent> <expr> , JumpToChar('','vb')

"-- Universal IDE-oid stuff:

	" F5-key pipes selected text to a file:
	vnoremap <F5> :<C-u>call AppendToFile()<Return>
	vnoremap <F1> :<C-u>call AppendToFile()<Return>
	nmap <F5> ggVG<F5><C-o><C-o>
	" F5-key just sends current line from insert-mode:
	imap <F5> <F1>
	" F1-key just sends current line to file:
	nmap <F1> V<F5>
	imap <F1> <C-o>mp<C-o><F1><C-o>`p

	" 2: altG opens command-bar:
	nnoremap <A-g> :
	vnoremap <A-g> :<C-u>

"-- Selection stuff

	" 2: shiftHome and shiftEnd select from current position to whatever
	" positions these are happed to jump to:
	nmap <S-Home> v<Home>
	nmap <S-End> v<End>

	" shiftW from normal mode selects current word cursor:
	nnoremap W viw
	" shiftW from visual mode deletes selection and spaces:
	vnoremap W w<Left>"_x
	nnoremap <C-w><C-w> db

	" 4: shiftRight/shiftLeft/shiftDown/shiftUp start visual selection in the
	" specified direction:
	nmap <S-Right> v<Right>
	nmap <S-Left> v<Left>
	nmap <S-Down> v<Down>
	nmap <S-Up> v<Up>
	" ctrlShiftRight starts visual selection by word to the left:
	nmap <C-S-Right> v<C-Right>
	" ctrlShiftLeft starts visual selection by word to the left:
	nmap <C-S-Left> v<C-Left>

	" ctrlA does select all:
	nnoremap <C-a> gg<S-v>G

	" shiftV enters line-select mode and moves the cursor to the end:
	nnoremap V V$

