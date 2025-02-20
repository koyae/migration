" Strip trailing whitespace on save:
augroup striptrailing
   autocmd!
   autocmd BufWritePre * :exec (&syntax!="snippets" && ShouldStripTrailing()==1)? '%s/\s\+$//e' : ""
augroup END

augroup reloadReadOnly
	autocmd!
	" This will automatically reload any buffers for which `autoread` has
	" been :set :
	autocmd CursorHold * checktime
augroup END


" Compatibility settings 1{{{
	:set nocompatible

	" **NOTE**: It's important to set `term` first because setting it can (at
	" least on certain systems) undo custom keycode definitions (the ones like
	" `set <C-Left> = b`)
	let term=$TERM
	if term == 'screen' || term == "screen-256color" || term == "xterm-256color"
	" if running from `screen`, assume xterm-signals:
		:set term=xterm
	endif

	:set <A-a>=a
	:set <A-b>=b
	:set <A-c>=c
	:set <A-d>=d
	:set <A-e>=e
	:set <A-g>=g
	:set <A-o>=o
	:set <A-p>=p
	:set <A-r>=r
	:set <A-s>=s
	:set <A-=>==
	:set <A-w>=w
	:set <A-x>=x
	:set <A-z>=z
	:set <A-(>=9
	:set <A-)>=0
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

	if match(system("uname -a"),"Darwin")==0
		" iTerm2 settings (comment) 2{{{
		"    Profiles -> Keys -> General:
		"        Allow application keypad mode
		"        xterm control sequence can enable modifyOtherKeys mode
		"        Left Option key = Esc+
		"    Profiles -> Keys -> Key Mappings
		"        optionLeft = Send Escape Sequence Esc+b
		"        optionRight= Send Escape Sequence Esc+f
		"    Profiles -> Text -> Font
		"        Menlo regular 18
		"    General -> Selection
		"        Copy to pasteboard on selection
		"        Applications in terminal may access clipboard
		" Other stuff (to allow ctrlUp and ctrlDown to work):
		"    Desktop and Dock -> Shortcuts ("Keyboard and Mouse Shortcuts" via
		"    search)
		"        Mission Control = (Hotkey disabled)
		"        Application windows = (Hotkey disabled)
		" }}}
		set <A-d>=á
		set <A-f>=æ
		set <A-q>=ñ
		" 2: ctrlLeft and ctrlRight seem to get trapped completely (nothing
		" gets sent) so we just assign optionLeft and optionRight:
		set <C-Left>=â
		set <C-Right>=f
	else
		:set <A-f>=f
		:set <A-q>=q
		:set <S-Left>=[D
		:set <S-Right>=[C
		:set <C-Left>=OD
		:set <C-Right>=OC
		:set <C-A-p>=
		:set <C-A-q>=
		:set <C-A-t>=
		:set <C-A-x>=
	endif

 " }}}

" Custom handling by filetype 1{{{
"
	augroup oddboyz
		autocmd!
		autocmd BufNewFile,BufRead, pom.xml,web.xml,*.yaml,*.ansible* setlocal tabstop=2 expandtab shiftwidth=2
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
		autocmd BufNewFile,BufRead, *.vim,.vimrc setlocal foldmethod=marker modeline
		" If vim is in its very own tab, with no other panes in that tab, open the FoldDigest pane at a
		" reasonable size
		autocmd BufWinEnter .vimrc if tabpagewinnr(tabpagenr(),'$') == 1 && winnr('$') == 1 | call FoldDigest() | silent Resize -h 45 endif
		autocmd BufNewFile,BufRead, *.vim,.vimrc setlocal comments+=:\\\\|
	augroup END

	augroup pgstuff
		autocmd!
		autocmd BufNewFile,BufRead, *.postgre.sql,scp://*.postgre.sql setf pgsql
		\| setlocal comments=:--
	augroup END

	augroup ultistuff
		autocmd!
		autocmd BufNewFile,BufRead, *.snippets setlocal comments=:#
	augroup END

" }}}

" Conventions 1{{{

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
"
" Conventions: function-names
" I use the convention "before" in function names to connote one CHARACTER before
" In turn "after" means the opposite.
" To connote the LINE before the cursor's current position, I use "above".
" In turn "below" means the opposite.

" }}}

" Plugin Settings and Imports 1{{{
	filetype plugin on
	source ~/.vim/plugin/cmdalias.vim

	if !empty(glob("~/.vimrc2"))
		source ~/.vimrc2
	endif

	" Cutlass overrides/settings 2{{{
		" We have to apply this mapping before pathogen loads cutlass:
		vnoremap d ""d
	" }}}2

	let g:pathogen_blacklist = []
	if has('signs') != 1
		call add(g:pathogen_blacklist, 'vim-bookmarks')
		echom "vim-bookmarks is not supported on this system"
	else
		let g:bookmark_sign = '🔖'
	endif

	let s:copilot = 0
	" If nodejs is not available, or it's an older version of vim, don't
	" try to load Copilot.
	silent let njs = system("nodejs --version")
	if v:shell_error || v:version < 900
	" ^ Note: `has('patch-9.0-0185')` should work according to
	" vi.stackexchange.com/questions/2466 but it doesn't seem to, so the
	" above is slightly imprecise; a few versions of vim 9.0 won't work,
	" which will have to be caught by the extension itself
		call add(g:pathogen_blacklist, 'copilot.vim')
		echom "copilot requires vim >=9.0.0185 and access to nodejs " .. v:shell_error .. njs
		" nodejs will typically break under WSL 1 so it's necessary to
		" upgrade to 2. Sufficiently-modern versions of vim begin to
		" appear under WSL Ubuntu 24.04.1 LTS and up.
	else
		let s:copilot = 1
	endif

	" grab everything from ~/.vim/bundle:
	execute pathogen#infect()
	runtime macros/matchit.vim " allow jumping to matching XML tags using '%'

	" Copilot settings 2{{{

		" Info about the free tier of Copilot:
		" * 2,000 code suggestions per month
		" * 50 Copilot chat messages per month
		" * Choice of Claude 3.5 Sonnet and GPT 4o
		" * Copilot extensions like Perplexity web-search
		" * 'Copilot Edits' for edits across multiple files

		" altLeft while in insert mode to scrub forward along suggestion
		" (built-in)

		if s:copilot == 1
			" altA accepts whole Copilot suggestion:
			imap <silent><script><expr> <A-a> copilot#Accept("\<CR>")
			let g:copilot_no_tab_map = v:true
			" if ! exists('g:copilot_workspace_folders')
			" 	let g:copilot_workspace_folders = ['~/.copilot_context']
			" endif
			" ^ At least for SQL files, doing this did not appear to have any
			" effect. Perhaps in the future, this will be resolved, but for
			" the moment, copilot.vim requires hacks.

			augroup copilot
				autocmd!
				" Start vim with Copilot disabled:
				autocmd VimEnter * :Copilot disable
				" When a new buffer is opened or we leave insert mode, disable
				" Copilot:
				autocmd BufNew,BufRead * :let b:copilot_enabled = v:false
				" Since both temporarily pausing insert mode (ctrlO) to perform
				" other actions and leaving insert mode wholesale both trigger
				" InsertLeave, we check which one has just occurred before we
				" switch Copilot off:
				autocmd InsertLeave * if match(mode('full'),'^ni')==-1 | let b:copilot_enabled = v:false | endif
				autocmd InsertEnter * let g:normal_mode_time=0
			augroup end

			" c-key enters insert-mode with Copilot turned on:
			nnoremap ci :Copilot enable<Return>:let b:copilot_enabled=v:true<Return>i
			" c-then-k enters insert-mode with Copilot turned on using the k-key
			" mapping:
			nmap ck :Copilot enable<Return>:let b:copilot_enabled=v:true<Return>k
			" c-then-a enters insert-mode with Copilot turned on by using the
			" a-key mapping:
			nmap ca :Copilot enable<Return>:let b:copilot_enabled=v:true<Return>a
			" c-then-shiftA enters insert-mode with Copilot turned on by using
			" the shiftA mapping:
			nmap cA :Copilot enable<Return>:let b:copilot_enabled=v:true<Return>A
		endif
	" }}}2

	" Ultisnips config: 2{{{
		" altQ expands snippet:
		let g:UltiSnipsExpandTrigger="<A-q>"
		" tab-key moves to next tabstop while snippets are active:
		let g:UltiSnipsJumpForwardTrigger="<tab>"
		" shiftTab moves to previous tabstop while snippets are active:
		let g:UltiSnipsJumpBackwardTrigger="[Z"
		let g:UltiSnipsEditSplit="vertical"
	" }}}2

	" Netrw config: 2{{{
		let g:netrw_banner=0
		" make netrw splits happen to the right (doesn't work with preview-splits,
		" even if they're set vertical :C):
		" let g:netrw_altv=1
	" }}}2

	" Taboo config: 2{{{
		" This isn't technically a Taboo setting, but doing this per the repo's
		" README allows tab names to be retained when using `:mksession`
		set sessionoptions+=tabpages,globals
	" }}}2

	" EightHeader config 2{{{
		" This makes fold-headers look a bit nicer, by using '.' as a
		" fill-character, indenting according to the fold-level, and also
		" indicating the indent-level with a leading number. e.g.:
		"     2 EightHeader config ................................10 lines
		let &foldtext = "EightHeaderFolds( '\\=s:fullwidth-2', 'left', [ repeat('    ', v:foldlevel - 1), '.', '' ], '\\= s:foldlines . \" lines\"', '\\=substitute(s:str,\"^\\\\(.*\\\\)\\\\([0-9]\\\\)$\",\"\\\\2 \\\\1\",\"\")' )"
		" NOTE: If this addon ever breaks, a custom function can just be
		" provided to the `foldtext` setting to override the default value
		" which causes the built-in `foldtext()` to be invoked. It'll take a
		" little bit of extra work, since EightHeader takes care of some
		" basics for us, but it shouldn't be too bad. Maybe I could even try
		" to expose the innards of a given header by making it multi-line.
	" }}}2

	" Folddigest config 2{{{
		let folddigest_options="vertical,nofoldclose,flexnumwidth"
	" }}}2

" }}}1

" User settings 1{{{

	" Display 2{{{
		colorscheme koyae
		" 4: Only turn on syntax highlighting once; this avoids turning
		" highlighting off when viewing/editing an unrecognized filetype for which
		" the user has already manually performed `set syntax=<syntax>` or `set
		" filetype=<filetype>`:
		if !exists('g:koyaeSyntaxEnabled')
			syntax enable
			let g:koyaeSyntaxEnabled = 1
		endif " :4
		let g:is_posix=1 " this will be right on 99% of systems
		if exists('+breakindent')
			:set breakindent
			" ^ paragraphs moved all the way over if there's an indent in front
			" (long line soft wrap)
		endif
		:set linebreak " whole-word wrapping instead of mid-word
		:set foldmethod=marker
	" }}}2

	" I/O 2{{{
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
	" }}}

  " Formatting behavior 2 {{{
		:set formatoptions+=j " allow vim's re-wrapping functionality to join as well as split
		" 3: wrap python-style arg-docs
		:set formatoptions+=n
		:set formatoptions-=2 " having the 2 flag set prevents n from working
		:set formatlistpat=^\\s\*[a-z][a-z_0-9]\\+[^-]\*\ \ --\ \ " :3 *
		" ^ * the end-of-line comment here is functional since it prevents the
		" trailing whitespace from being stripped

		" Disable highlighting of non-capitalized words that follow periods; IMO
		" this is so noisy that it hurts more than it helps:
		:hi SpellCap none
	" }}}2

	" cmdalias.vim aliases (vanilla): 2{{{
		:Alias Wq wq
		:Alias WQ wq
		:Alias qw wq
		:Alias Q q
		:Alias w W
	" }}}2

  " Custom commands 2{{{

		:command! ArgTranspose call TransposeArgs()

		:command! -nargs=? W call RobustSave(<f-args>)
		:command! Reup source ~/.vimrc
		:Alias reup Reup
		" Create a new tab with the desired help-page inside of it:
		:command! -nargs=1 Tabh tab h <args>
		:Alias tabh Tabh
		:command! -nargs=+ Resize call Resize(<f-args>) " TODO: handle percents. https://www.reddit.com/r/vim/comments/3m85zo/resizing_splits_as_a_percentage_in_macvim/
		:command! Hoh set hlsearch
		:Alias hoh Hoh
		" Count the number of commas on the current line:
		:command! Comman keeppattern s/,//n
		" Run vim's grep in a new tab if necessary:
		:command! -nargs=+ Grep execute (&modified)? "tabe" : "" | grep <args>
		Alias grep Grep
		:command! Grepr Grep -r <args> .
		Alias grepr Grepr
		:command! -nargs=+ Greprt tabe | grep -r <args> .
		Alias greprt Greprt

		:command! -range=% Imply <line1>,<line2>s/^./>\0/ | noh
		" Soft-yank a line (or line-range) and then immediately paste it at the
		" cursor's current position:
		:command! -range Yp <line1>,<line2>y p | normal! "pP
		Alias yp Yp
		" ^ This won't correct to 'Yp' on <Return> or <Space> but it will correct on
		" <Tab> so to yank-then-paste the line above it would be :-1yp<Tab>

		" Turn tabs into spaces for either the current line, or the lines indicated
		" using the preceding range-syntax:
		:command! -range Poof setlocal expandtab | <line1>,<line2>retab! | setlocal noexpandtab

		" This command prefixes/prepends the given text to the beginning of the
		" selected lines, or all lines, if it's invoked with no selection:
		:command! -range=% -nargs=+ Beg silent <line1>,<line2>call InsertAtBeginning(<f-args>)
		Alias beg Beg

		" Copy path to current file into default register #current path
		:command! Cpath let @"=escape(expand('%:p'),' \')
		Alias cpath Cpath

		" Change the current working directory to that of the current file:
		command! Nowat lcd %:p:h
		Alias nowat Nowat

		Alias ulti UltiSnipsEdit

		command! Comred hi Comment ctermfg=Red

		" Grab either the lefthand side or righthand side of a nearby line and paste
		" it to the current line:
		:command! -range Lhs :normal! mw<line1>gg^"pyf=`w"pp<Return>
		Alias lhs Lhs
		:command! -range Rhs :normal! mw<line1>gg^f=l"py$`w"pp<Return>
		Alias rhs Rhs
		:command! -range Dp <line1>m .
		:Alias dp Dp

	" }}}2

" }}} 1

" Functions 1{{{

  " Note `function!` forces overwrite if necessary on creation of a funciton

	if ! exists('*ShouldStripTrailing')
	" On certain systems, this may be defined in .vimrc2 already
		function ShouldStripTrailing()
			return 1
		endfunction
	endif

	" SuSave([path [,escape]])
	"
	" path    --  the path to which the current buffer should be saved. If
	"             omitted, this defaults to whatever the current save-path
	"             already is.
	" escape  --  1 or 0 indicating whether the path should be escaped for use
	"             on the shell or not. If omitted, it's assumed this is not
	"             needed and has already been done.
	function! SuSave(...)
	" Code adapted from vim.fandom.com/wiki/Su-write
		let path=expand("%:p")
		let escapePath=0
		if a:0 > 0
			let path=a:1
			if a:0 > 1
				let escapePath=a:2
			endif
		else
			let escapePath=1
		endif
		if escapePath==1
			let path=shellescape(path)
		endif
		let fname=tempname()
		exec 'w ' . fnameescape(fname)
		let owners=GetOwners(path)
		let modes=GetPermissions(path)
		silent exec '!sudo cp' shellescape(fname) path
		call SetAccess(path, modes, owners)
	endfunction

	" GetOwners(filePath)
	" It's assumed filePath is already shellescape()'d
	function! GetOwners(filePath)
		return shellescape(system('stat --printf=%U:%G ' . a:filePath))
	endfunction

	" GetPermissions(filePath)
	" It's assumed filePath is already shellescape()'d
	function! GetPermissions(filePath)
		return system('stat -c%a ' . a:filePath . ' | tr -d "\n"')
	endfunction

	" Adjust the ownership and permissions-bits of a given file.
	"
	" target  --  path to the file to work on. This should already be
	"             shellescaped()'d
	" modes   --  chmod mode-bits to set e.g. 600 or 0600. Pass an empty
	"             string if you don't care about mode
	" owners  --  first argument to chown. This can be either the name of a
	"             single user or <userName>:<groupName> if you wish to set
	"             both. Pass an empty string if you don't care about ownership
	function! SetAccess(targetFile, modes, owners)
		if a:modes
			silent exec '!sudo' "chmod" a:modes a:targetFile
		endif
		if a:owners
			silent exec '!sudo' "chown" a:owners a:targetFile
		endif
	endfunction

	" Prepare a given vim-style SCP-path for use with real SCP. Cygwin doesn't
	" seem to need this but Ubuntu does.
	function! SCPify(targetPath)
		let rval = a:targetPath
		if match(rval,'^scp://[a-z_0-9]\+//.*')!=-1
			let rval = substitute(rval,'^scp://','','')
			let rval = substitute(rval,'//',':/','')
		endif
		return rval
	endfunction

	" RobustSave([targetPath])
	" A (somewhat) robust wrapper for :W and :sav that avoids
	" https://github.com/vim/vim/issues/1268 if SCP-paths contain spaces, which
	" also uses AsyncRun to perform network writes, preventing Vim from
	" temporarily hanging/freezing while waiting on IO on slow connections.
	"
	" targetPath  --  the path to which the buffer-contents should be written
	"
	" If you wish to save both a local file and a remote file every time this
	" function is called, you can set the value of b:robustsave_alt_path. For example:
	" let b:robustsave_alt_path = getcwd() .. '/' .. substitute(expand('%:t'),'\\ ',' ','')
	" Assuming the current buffer is pointed at a remote SCP address with a
	" space in the path, this will take that basename, unescape the spaces
	function! RobustSave(...)
		let naturalpath = expand('%:p')
		let path = naturalpath
		if a:0 == 1
			let path = expand(a:1)
		endif
		if ( match(path, "scp://") == 0 )
		" ^ if the remote filename might cause problems with how netrw tries to
		" invoke scp, correct before saving:
			let tmpfile = exists('b:robustsave_alt_path') ?
				\ b:robustsave_alt_path
				\ : exists('b:netrw_tmpfile') ?
				\ b:netrw_tmpfile
				\ : escape(tempname(),' ')
			execute "write! " . tmpfile
			" Replace any space that is not proceded by a backslash with the
			" literal: '\ ':
			let path = shellescape(substitute(SCPify(path), '\(\\\)\@<! ', '\\ ', 'g'))
			let l:doMe='AsyncRun'
				\ . ' -post=echo\ "delayed\ write"\ g:asyncrun_status\ strftime(''\%X'')'
				\ . '\ |\ if\ g:asyncrun_status=="success"'
				\ . '\ |\ set\ nomod'
				\ . '\ |\ :endif '
				\  . "scp " . shellescape(tmpfile)
				\ . " " . path
			" ^ inspired by:
			" github.com/skywind3000/asyncrun.vim/wiki/Get-netrw-using-asyncrun-to-save-remote-files
			"echom l:doMe
			execute doMe
			return
		endif
		if naturalpath != path && match(naturalpath,'^scp://') == 0
			let path = substitute(path, '\\ ', '\ ', '')
		endif
		" Check file is writeable to current user
		let writetest = "test -w " . shellescape(path)
			\ . " || touch " . shellescape(path)
		call system(writetest)
		let couldNotWrite=v:shell_error

		if couldNotWrite
			echo "Did not have permissions to write file. Try to su? "
			let response=nr2char(getchar())
			if response=="y" || response=="Y"
				call SuSave()
			else
				redraw
				echo "Write-op cancelled."
			endif
		else
		" otherwise, just write (pretty much) as normal:
			let sePath=shellescape(path)
			let perms=GetPermissions(sePath)
			let owners=GetOwners(sePath)
			" if the original path of the current buffer is different from the
			" file we're being told to save (write) and is an SCP address,
			" reduce the backslashes so we don't write files with backslashes
			" locally:
			let doMe="write " . fnameescape(path)
			try
				execute doMe
			catch /^Vim\%((\a\+)\)\=:E13:/
				echo "File " . path . " exists. Overwrite? "
				let response=nr2char(getchar())
				if response=="y" || response=="Y"
					execute substitute(doMe,'^write','write!','')
				else
					echo "File-write aborted."
					return
				endif
			endtry
			let newPerms=GetPermissions(sePath)
			let newOwners=GetOwners(sePath)
			if perms!=newPerms || owners!=newOwners
				echo "Permissions changed on write. Use su to adjust? "
				let response=nr2char(getchar())
				if response=="y" || response=="Y"
					call SetAccess(sePath, perms, owners)
				endif
			endif
		endif
	endfunction

	" InsertAtBeginning(['-q'|'-Q',] whatToInsert)
	function! InsertAtBeginning(first,...) range
		let doQuotes = 0
		let args = a:000
		if a:first == '-q'
			let doQuotes = 1
			let args += ['"']
		else
			let args = [a:first]
			let args += a:000
		endif
		let whatToInsert = join(args,' ')
		execute a:firstline . ',' . a:lastline . 's/^/' . whatToInsert
		if doQuotes
			execute a:firstline . ',' . a:lastline . 's/$/"'
		endif
	endfunction

	function! Resize(first,...)
		" echom type(a:first)
		if a:0 == 0
		" if no extra arguments given:
			echom "resize " . a:first
			resize a:first
		elseif a:first == "-v"
		" if direction (vertical) was given first:
			echom "resize " . a:1
			execute "resize " . a:1
		elseif a:1 == "-v"
		" if direction (vertical) was given second:
			echom "resize " . a:first
			execute "resize " . a:first
		elseif a:first == "-h"
		" if direciton (horizontal) was given first:
			echom 'vertical resize ' . a:1
			execute "vertical resize " . a:1
		elseif a:1 == "-h"
		" if direction (horizontal) was given second:
			echom "vertical resize " . a:first
			execute "vertical resize " . a:first
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

	" Get the ID of the current screen session (assuming we're inside one
	" presently) e.g. '4105.T'
	function! GetScreenSession()
		let results = system('screen -wipe | grep "Attached" | cut -f	2')
		return substitute(results, "\n", '', '')
	endfunction

	" ScreenDo(minusXArgs[,redraw[,windowId[,sessionId]]])
	"
	" Pass a command to GNU Screen to have it executed
	"
	" minusXargs  --  the arguments to give to Screen's `-X` flag
	"
	" redraw      --  integer representing whether to redraw vim's UI, since
	"                 screen can mess it up in console.
	"                 Defaults to: 1 (true/on)
	"
	" windowID    --  the task (window) which the screen-command should affect
	"                 Defaults to: window 0 (if omitted or empty string given)
	"
	" sessionID   --  the screen session-identifier. Defaults to: current
	"                 session (if omitted or empty string given)
	"
	function! ScreenDo(minusXArgs,...)
		let redraw = 1
		let sessionId = GetScreenSession()
		let windowId = '0'
		if a:0 > 1
			let redraw = a:1
		endif
		if a:0 > 2
			let windowId = a:2
		endif
		if a:0 > 3 && string(a:3)!=''
			let sessionId = a:3
		endif
		silent exec '!screen -dr ' . sessionId . ' -p ' . windowId . ' -X ' . a:minusXArgs
		redraw!
	endfunction

	" ToJumpToIdent([backwards[,indentToMatch[,ignoreWhite]]])
	" move the cursor from the current line to either the end of the current
	" block (by indentation) or the next line that has the same indent-level but
	" is not part of the block
	function! ToJumpToIndent(...)
		let backwards = 0
		if a:0 > 0
			let backwards = a:1
		endif
		let indentToMatch = matchstr(getline('.'),'^\s*')
		if a:0 > 1
			let indentToMatch = a:2
		endif
		let ignoreWhite = 1
		if a:0 > 2
			let ignoreWhite = a:3
		endif
		let startnr = line('.')
		let increment = (backwards)? -1 : 1
		let linenr = startnr " current line-number as candidate to jump to
		let lastMatchNr = startnr " where the last match we found was
		let run = 1
		"^ tracks whether we've had continuous matches between the start and the
		" iteration previous to the current one
		while (backwards)? linenr>=line('^') : linenr<=line('$')
			let linenr += increment " move to next line
			let line = getline(linenr)
			let isWhite = (match(line,'\S')==-1)
			let matched = 1 " whether we had a match this time
			let leadingWhitespace = matchstr(getline(linenr),'^\s*\([^ \t]\)\@=')
			if leadingWhitespace!=indentToMatch
				if !ignoreWhite || (ignoreWhite && !isWhite)
					let matched = 0
				endif
				if !isWhite && strlen(leadingWhitespace) < indentToMatch
				" Generally, we won't want to jump to a matching indent-level if
				" there's an intervening indent that's LESS than what we started
				" with, so if we encounter that, we jump out if there's already
				" a jump-target:
					if lastMatchNr != startnr
						return lastMatchNr . 'gg'
					else
						return ""
					endif
				endif
			else
			" if we matched, record the last line on which that occurred:
				let lastMatchNr = linenr
			endif
			if lastMatchNr!=startnr && ((!run && matched) || (run && !matched))
			" if we've identified a jump-point other than the start-line, AND:
			" A) we've just hit the end of the current block (`run && !matched`)
			" or
			" B) we've found the next block of the same indent size after
			" crossing a patch of differently-indented code (`!run && matched`)
				break
			endif
			if !matched
				let run = 0
			endif
		endwhile
		if startnr == lastMatchNr
		" if the while-loop failed to find any matches:
			return ""
		else
			return lastMatchNr . "gg"
		endif
	endfunction

	" Call this function if the argument-list to a function has grown too long,
	" for one line, even if you go down a line to provide arguments only before
	" closing out the call. This provides a way to sanely wrap each argument,
	" even if there are strings containing commas or things that would screw up
	" something simpler like a basic macro:
	function! TransposeArgs()
		" Note: we're currently making the assumption the args have already been
		" put on their own line, so jump to the first right away:
		normal ^
		let startpos = getcurpos()
		let repcount = 0
		while startpos[1] == line('.')
		" So long as we're still on the same line, keep repeating the motion to
		" visit the next argument, keeping track of how many times we've
		" done it:
			normal 1],
			let repcount += 1
		endwhile
		" Reset the cursor position and use the number of repeats we determined
		" to jump to the dividing comma between each argument, move right one
		" character, then insert a new line after the comma, which will match
		" indent (or not) on the next line according to vim's `formatoptions`
		call setpos('.',startpos) " reset cursor position
		let doThis = repeat("1],\<Right>\<Return>", repcount-1)
		execute 'normal ' .. doThis
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

	" :[<startline>,<stopline>]call PgCap()
	"	capitalize all Postgres keywords on the given lines or -- if range is
	"	omitted -- on the current line
	"
	" PgCap(lineNumber, columnNumber)
	" 	capitalize	the character at the designated location if it is
	" 	a Postgres keyword.
	"
	function! PgCap(...) range
		let capThese = ['pgsqlKeyword','pgsqlOperator','pgsqlType','pgsqlVariable']
		if a:0==2
			let kwType = synIDattr(  synID( a:1, a:2, 1 ), "name"  )
			if index(capThese,l:kwType) >= 0
				normal! vgU
			endif
		else
			set syntax=pgsql
			let curLine = a:firstline
			while curLine<=a:lastline
				let curPos=1
				while curPos<=len(getline(curLine))
					let kwType = synIDattr(  synID( curLine, curPos, 1 ), "name"  )
					if index(capThese,l:kwType) >= 0
						let doString = curLine . ',' . curLine . 's/\(\%' . curPos . 'c.\)/\U\1'
						execute doString
					endif
					let curPos += 1
				endwhile
				let curLine += 1
			endwhile
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
			" echom "a"
			return '$'
		else
			" echom "b"
			return (a:mode=='v')? "g$\<Left>" : 'g$'
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
		let mode = mode(1) " get full mode
		let smartStuff = "j:s/^\\s\\+//e | noh\<Return>0i\<BS>\<C-o>mp\<Esc>`p"
		if AtEndOfLine()
			if mode == "i"
				return "\<Esc>" .. smartStuff .. "i"
			else
				return smartStuff
			endif
		elseif mode == "i"
			return "\<Del>"
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

	" Return the character currently found under the cursor
	function! GetCurrentChar()
		return matchstr(getline('.'), '\%' . col('.') . 'c.')
		" Expression courtesy https://stackoverflow.com/a/23323958/5739296
	endfunction

	function! GetRegexFromSelection()
		let txt = escape(GetSelectionText(),'/\')
		let txt = substitute(txt,"\n",'\\n','g')
		let txt = substitute(txt,"\t",'\\t','g')
		return '\V\(' . txt . '\)'
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
			echom 'char: ' . char
			call search('\V' . char, 'w'. searchFlags)
		endif
		call RestoreSetting('ignorecase')
		call RestoreSetting('smartcase')
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
		if &modified
			 echom 'Discard modifications?'
			 let @r = nr2char( getchar() )
			 if @r == 'n'
				 return
			 endif
		 endif
		if tabCount > 1
			if currentTab > 1 && currentTab < tabCount
			" if current tab is neither the first tab nor the last:
				q!
				tabprev
			else
				q!
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

	" AppendToFile([text[,fifoPath]])
	" Append the current selection or given text to a specified file.
	"
	" The primary intent for this file is to allow writing to (fifo)-files which
	" are being monitored within a continuous loop by one or more outside
	" utilities, to allow code-snippets to be executed from vim without changing
	" windows/panes.
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
			\ 'pgsql': "\n\\set ECHO none\n\\pset footer off\n\\pset tuples_only on\n;SELECT '(vim) All done (vim)';"
		\ }
		" duplicate the pgsql key for sql:
		let suffdict.sql = suffdict.pgsql
		let text = (a:0 >= 1)? a:1 : GetSelectionText()
		let fifoPath = (a:0 >= 2)? a:2 : '/tmp/fif'
		let fulltext = text
		" Only add footer if appended text was nonempty:
		if fulltext != ""
			let fulltext = text . get(suffdict,&syntax,'')
		endif
		call writefile(
			\ split( fulltext, "\n", 1 ),
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

" }}}1

" Minesweeping 1{{{

	" shiftK doesn't to try look up any man-pages for the word under the cursor:
	nnoremap K <Nop>

" }}}1

" Novel keybindings 1{{{

	" Write the current file as root (for if you forget to sudoedit or later
	" open another buffer that requires this): # late sudoedit
	cmap w!! write !sudo tee % >/dev/null
	" Fun fact the above does not work in neovim/nvim:
	" https://github.com/neovim/neovim/issues/1716

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

	" 4: altR removes the function-call currently under the cursor.
	" Note that the cursor can be on the function-name, the opening
	" parenthesis, or the closing parenthesis. 4:
	nmap <A-r> :if match(GetCurrentChar(),'[()]')!=-1
		\ \| execute 'normal ' . (GetCurrentChar()==')'? '%' : '') . 'i_'
		\ \| endif
		\ \| :normal viwxm`%x``x<Return>
	imap <A-r> <C-o><A-r>
	" 2: ctrlE sets enclosure function and encloses the current word or
	" selection with a function-call:
	nnoremap <C-e> :call SetEncloseWithFunctionCallFunctionName()<Return>
	imap <C-e> <C-o><C-e>
	" 4: altW encloses the current word or selection with a function-call:
	nmap <A-w> :let @p=g:EncloseWithFunctionCallFunctionName
		\ \| normal viw(%"pP`[<Return>
	imap <A-w> <C-o><A-w>
	vmap <expr> <C-e> SetEncloseWithFunctionCallFunctionName("\<A-w>")
	vmap <A-w> :<C-u>let @p=g:EncloseWithFunctionCallFunctionName<Return>gv(%"pP
	" ^ set register, restore selection, jump to matching parenthesis, paste

	" altC clears trailing whitespace if present then places a colon at EOL:
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
	" ctrlAltP pastes above current line:
	nmap <C-A-p> O-p
	imap <C-A-p> <C-o>:normal <C-A-p><Return>
	" openparen surrounds current selection in parentheses from visual mode:
	vnoremap <silent> ( <Esc>:let @s=@"\|set paste<Return>gv<C-g>(<C-r>")<Esc>:let @"=@s\|set nopaste<Return>
	" ^ Save default register in register 's', regain selection, enter SELECT
	" mode and overtype selection with a '(' then paste whatever we just
	" replaced again then write a ')'. Return to normal mode and reset paste
	" state and restore default register.
	" closeparen does the same as above:
	vmap <silent> ) (
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
	vnoremap "/ "pygv"=RelimitRegister('p',"/",'')<Return>P
	" [quote-dollar-dollar] [quote-dolla-dolla]
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

	" tab-key increases indent:
	nnoremap <Tab> ><Right>
	vnoremap <Tab> >gv
	imap <expr> <Tab> (match(getline('.'),'^\s*$')!=-1)?
		\ "\<C-r>=\"\\t\"\<Return>"
		\ : "\<C-o>m`\<C-o>\<Tab>\<C-o>``\<Right>"
			\ . repeat("\<Right>", col('.')==col('$'))
	" ^ Under certain conditions (like immediately following a <Return>) <C-o>
	" seems to be wipe out all initial tabs when there are no following
	" characters, so we use the '=' register to produce a tab-character instead.
	" When we have characters other than just tabs, we want to restore the
	" position of the cursor. Since <C-o> puts the cursor back TWO spaces if
	" it's at the end of the line, we go back over two if that's where it was

	" shiftTab reduces indent:
	nnoremap <S-Tab> <<Left>
	vnoremap <S-Tab> <gv
	imap <S-Tab> <C-o>m`<C-o><S-Tab><C-o>``<Left>

	" altB groups a selected set of arguments spread across multiple lines onto
	" one line:
	vnoremap <A-b> :s/,\n\s*/, /<Return>

	" altEquals adds a space after (sequences of) '>' which begin a line:
	vmap <A-=> :sm/^\(>\+\)\([^ >]\)/\1 \2/ <Return>:noh <Return>
	nmap <A-=> :%sm/^\(>\+\)\([^ >]\)/\1 \2/ <Return>:noh <Return>

	" d-then-minus decrements the nearest integer at/after the cursor:
	nnoremap d- <C-x>
	" d-then-plus increments the nearest integer at/after the cursor:
	nnoremap d+ <C-a>

" }}}1

" Keybinding overrides 1{{{

	" facade-g actually exits insert-mode and prepares to run a g-prefixed
	" command. Without this binding, I'm constantly gotten because I'll leave
	" insert-mode to go somewhere (e.g. next tab, top of document, bottom of
	" current function via gz but then instead a ç is printed, because I didn't
	" wait long enough for escape to bring me out, so it gets interpreted as a
	" character):
	imap ç <C-c>g

	" Emmet bindings: 2{{{
		" altZ expands tags instead of Emmet's default ctrlY-then-comma:
		imap <A-z> <C-Y>,
	" }}}2

	" Navigation bindings: 2{{{

		" Folding bindings: 3{{{
			nnoremap zn zj
			nnoremap zp zk
		" }}}3

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

		"2: o-key and altO insert a line below or above the current one (without
		"staying in insert mode):
		nmap <silent> <expr> <A-o> InsertLineBelow() . "\<Esc>``"
		nmap <silent> <expr> o InsertLineBelow() . "\<Esc>"
		" shiftO inserts a line above the current one:
		nmap <silent> <expr> O InsertLineAbove() . "\<Esc>"

		" backslash-key inserts a backslash:
		nmap <silent> <expr> \\ ToInsertBeforeCurrentChar('\') . "\<Right>"
		" space inserts a space in front of current character:
		noremap <silent> <expr> <Space> ToInsertBeforeCurrentChar(" ")

		" h-key goes up one line:
		nnoremap h k
		" l-key goes down one line:
		nnoremap l j

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
		nnoremap <expr> gi ToJumpToIndent()
		vnoremap <expr> gi ToJumpToIndent()
		" g-then-shiftI goes to the previous matching indent:
		nnoremap <expr> gI ToJumpToIndent(1)
		vnoremap <expr> gI ToJumpToIndent(1)

		" allow shiftLeft to stay held while selecting without jumping by word
		vmap <S-Left> <Left>
		" allow shiftRight to stay held while selecting without jumping by word
		vmap <S-Right> <Right>
		" allow shiftDown to stay held while selecting without jumping by screen
		vmap <S-Down> <Down>
		" allow shiftUp to stay held while selecting without jumping by screen
		vmap <S-Up> <Up>
		" ctrlRight jumps only to the beginning words that I consider words:
		nnoremap <silent> <C-Right> :set nohlsearch \| let @s=@/<Return>/\<[a-zA-Z0-9_]<Return>:let @/=@s<Return>
		" ctrlLeft jumps only to the beginning of words that I consider words:
		nnoremap <silent> <C-Left> :set nohlsearch \| let @s=@/<Return>?\<[a-zA-Z0-9_]<Return>:let @/=@s<Return>
		" ctrlRight jumps by word like in most text editors:
		vnoremap <C-Right> /[a-zA-Z0-9_]\><Return>
		" ctrlLeft jumps by word like in most text editors:
		vnoremap <C-Left> ?\<[a-zA-Z0-9_]<Return>

		" 2: shiftLeft and shiftRight switch to selection-mode:
		imap <S-Left> <C-o>mv<Esc>`vv<Left>
		imap <S-Right> <C-o>mv<Esc>`vv<Right>

		":4 sadly the previous two aliases do not quite work in PuTTY
		imap <silent> <C-Right> <C-o>:set nohlsearch \| let @s=@/<Return><C-o>/\<[a-zA-Z0-9_]<Return><C-o>:let @/=@s<Return>
		imap <silent> <C-Left> <C-o>:set nohlsearch \| let @s=@/<Return><C-o>?\<[a-zA-Z0-9_]<Return><C-o>:let @/=@s<Return>
		" altE goes to (after) end of word:
		imap <A-e> <C-o>e<Right>
		nmap <A-e> e
		" altB goes to beginning of word:
		imap <A-b> <C-o>b

		" 2: j-key jumps to the next/previous character which matches the one under
		" the cursor:
		nnoremap <silent> j :call JumpToNextMatchingChar('')<Return>
		vnoremap <silent> J :<C-u>let @p=escape(GetCharFromCursor(),'/\') \| set nohlsearch<Return>gv?\V<C-r>p<Return>
		" 2: shiftJ does the same only backwards:
		nnoremap <silent> J :call JumpToNextMatchingChar('b')<Return>
		vnoremap <silent> j :<C-u>let @p=escape(GetCharFromCursor(),'/\') \| set nohlsearch<Return>gv/\V<C-r>p<Return>

	" }}}2

	" Editing bindings 2{{{

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
		inoremap <silent> <expr> <Del> SmartDelete()
		noremap <silent> <expr> <Del> SmartDelete()
		nnoremap <silent> <expr> x SmartX()
		" ctrlDelete deletes rest of line
		nmap <C-kDel> v<S-$><Left>x

		" ctrlBackspace deletes previous word:
		nmap  i<C-w><Esc>x

		" altD eats next word / deletes next word:
		nmap ä <A-d>
		nnoremap <silent> <A-d> :call EatNextWord() <Return>
		imap ä <A-d>
		inoremap <silent> <A-d> <Right><Esc>:call EatNextWord() <Return>i

		" s-key does not yank, just deletes then enters insert-mode:
		vnoremap <expr> s SmartS()
		vmap a s<Right>
		nnoremap <expr> s SmartS()
		" x-key does not yank, just deletes:
		vnoremap <expr> x SmartX()
		" p-key and shiftP do not yank, just:
		vnoremap p "_xP
		vnoremap P "_xP

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

	" }}}2


	" Find and replace stuff 2{{{

		" ctrlF opens search-mode:
		nnoremap <C-f> /
		vnoremap <C-f> "fy/\V<C-r>f
		" hash-key and star-key (asterisk-key) search on current selection as a token:
		" TODO: we'll need to actually escape the clipboard-contents instead of
		" using \V, since \V disables use of \< and \>
		vnoremap * "fygv/\V\<<C-r>f\><Return>
		vmap # "fygv?\V\<<C-r>f\><Return>
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
		vnoremap <C-r> :call SelectionAsRegexToRegister('h')<Return>:<C-u>%s/<C-r>h//<Left>
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

		" 4: f-key finds the next single character (accepted afterwards
		" interactively) on multiple lines, rather than just the current one:
		nnoremap <silent> <expr> f ((mode()=="i")? "m`" : "") . ":call FindChar('')\<Return>"
		" ^ from normal mode, this also marks the current position for return, which
		" functionally skips this step if done from insert-mode using ctrlO:
		vnoremap <silent> <expr> f 'm`' . FindChar('v')
		" 2: shiftF finds previous single character (accepted afterwards
		" interactively):
		nnoremap <silent> <expr> F ((mode()=="i")? "m`" : "") . ":call FindChar('b')\<Return>"
		vnoremap <silent> <expr> F 'm`' . FindChar('vb')
		" 2: semicolon-key repeats previous FindChar search:
		nnoremap <silent> ; :call JumpToChar('','')<Return>
		vnoremap <silent> <expr> ; JumpToChar('','v')
		" 2: comma-key repeats previous FindChar search backwards:
		nnoremap <silent> , :call JumpToChar('','b')<Return>
		vnoremap <silent> <expr> , JumpToChar('','vb')
	" }}}

	" Universal IDE-oid stuff 2{{{

		" See also the binding for Copilot mode found in the "Copilot settings"
		" section.

		" F5-key pipes selected text to a file:
		vnoremap <F5> :<C-u>call AppendToFile()<Return>
		vnoremap <F1> :<C-u>call AppendToFile()<Return>
		nmap <F5> ggVG<F5><C-o><C-o>
		" F5-key just sends current line from insert-mode:
		imap <F5> <F1>
		" F1-key just sends current line to file:
		nmap <F1> V<F5>
		imap <F1> <C-o>mp<C-o><F1><C-o>`p

		vnoremap <F10> :<C-u>call AppendToFile(GetSelectionText(),'/tmp/lifo')<Return>
		vnoremap <F6> :<C-u>call AppendToFile(GetSelectionText(),'/tmp/lifo')<Return>
		nmap <F10> ggVG<F6><C-o><C-o>
		" F10-key just sends current line from insert-mode:
		imap <F10> <F6>
		" F6-key just sends current line to file:
		nmap <F6> V<F10>
		imap <F6> <C-o>mp<C-o><F6><C-o>`p

		" 2: altG opens command-bar:
		nnoremap <A-g> :
		vnoremap <A-g> :
	" }}}2

	" Selection stuff "{{{

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
	" }}}2

" }}}1
