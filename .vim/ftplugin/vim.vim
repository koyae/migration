" Don't force code to wrap:
setlocal formatoptions-=t

" execute current selection as vimscript take make testing easier:
command! Vex execute GetSelectionText()
Alias vex Vex
