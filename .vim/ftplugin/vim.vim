" Don't force code to wrap:
setlocal formatoptions-=t
setlocal formatoptions+=r

" execute current selection as vimscript take make testing easier:
command! -range Vex execute GetSelectionText()
Alias vex Vex
