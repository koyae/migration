" Vim color file
" Maintainer:	Koyae <CronoCat@hotmail.com>
" Last Change:  2015 Mar 18
hi clear

let colors_name = "koyae"

" Basic stuff
hi Normal     guifg=Black  guibg=White
hi Cursor     guifg=bg     guibg=fg
hi lCursor    guifg=NONE   guibg=Cyan

" Note: we never set 'term' because the defaults for B&W terminals are OK
" Also keep in mind that a typical PuTTY window only reads ctermbg and ctermfg
" Differentiable NR-8 xterm colors are: Black Blue Green Cyan
" Red Magenta Brown Yellow White Grey
hi DiffAdd      ctermbg=Green guibg=Brown ctermfg=White cterm=bold
hi DiffChange   ctermbg=Black
hi DiffDelete   ctermfg=Blue ctermbg=LightRed
hi DiffText     cterm=bold gui=bold ctermbg=Brown
hi Directory    ctermfg=DarkBlue guifg=Blue
hi ErrorMsg     ctermfg=White ctermbg=DarkRed guibg=Red guifg=White
hi FoldColumn   ctermfg=DarkBlue ctermbg=Grey guibg=Grey guifg=DarkBlue
hi Folded       ctermbg=Grey ctermfg=DarkBlue guibg=LightGrey guifg=DarkBlue

" Used before enter is pressed and `incsearch` is on:
hi IncSearch    cterm=reverse gui=reverse
" Used after enter is pressed and `hlsearch` is on:
hi Search       cterm=reverse ctermfg=DarkGrey gui=reverse

hi LineNr       ctermfg=LightMagenta guifg=Brown cterm=bold gui=underline
hi ModeMsg      cterm=bold gui=bold
hi MoreMsg      ctermfg=DarkGreen gui=bold guifg=SeaGreen
hi NonText      ctermfg=Blue gui=bold guifg=gray guibg=white
hi Pmenu        guibg=LightBlue
hi PmenuSel     ctermfg=White ctermbg=DarkBlue guifg=White guibg=DarkBlue
hi Question     ctermfg=DarkGreen gui=bold guifg=SeaGreen
hi Search       ctermfg=NONE ctermbg=Grey guibg=Yellow guifg=NONE
hi SpecialKey   ctermfg=DarkBlue guifg=Blue
hi StatusLine   cterm=bold ctermbg=Black ctermfg=white guibg=gold guifg=blue
hi StatusLineNC ctermbg=Black ctermfg=Grey guibg=blue guifg=black
hi Title        ctermfg=DarkMagenta gui=bold guifg=Magenta
hi VertSplit    cterm=reverse gui=reverse
hi Visual       ctermbg=Yellow ctermfg=Black cterm=bold guifg=Grey guibg=fg
hi VisualNOS    cterm=underline,bold gui=underline,bold
hi WarningMsg   ctermfg=DarkRed guifg=Red
hi WildMenu     ctermfg=Black ctermbg=Yellow guibg=Yellow guifg=Black

" syntax highlighting
hi Comment    cterm=NONE ctermfg=DarkGrey gui=NONE guifg=red2
hi Constant   cterm=NONE ctermfg=Magenta   gui=NONE guifg=green3
hi Identifier cterm=NONE ctermfg=DarkCyan    gui=NONE guifg=cyan4
hi PreProc    cterm=NONE ctermfg=DarkMagenta gui=NONE guifg=magenta3
hi Special    cterm=NONE ctermfg=LightRed    gui=NONE guifg=deeppink
hi Statement  cterm=bold ctermfg=Blue	     gui=bold guifg=blue
hi String     cterm=NONE ctermfg=DarkYellow   gui=NONE guifg=SkyBlue
hi Type	      cterm=NONE ctermfg=Blue	     gui=bold guifg=blue

