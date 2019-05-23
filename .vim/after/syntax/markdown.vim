" Vim's way of highlighting markdown has a special syntax-group for showing
" internal underscores in red (e.g. 'variable_name') which is done to indicate
" that this is a problem. Strictly speaking, this may indeed be an error, but
" most modern Markdown-parsers do not have any trouble dealing with these, and
" some will even literally render the intuitive correction of '\_' (which vim
" considers acceptable).
"
" Since the `markdownError` syntax-group only refers to this one particular
" thing, we can just turn off the highlighting for it:
hi! def link markdownError NONE
" ^ Note: Before settling on the above, I tried `syn clear markdownError`, but
" -- though arguably neater -- this is won't work because it causes italics to
" leak everywhere.  In other words, the group is needed to prevent italics
" from being set off by internal underscores, but should arguably just
" display as normal text, rather than being highlighted as erroneous.

" Next we unlink htmlError for Markdown, as this highlights greater-than and
" less-than signs (angle brackets) when they are used for reasons other than
" html-tags, like to express comparisons. Since most Markdown I've ever seen
" has only one or two bits of HTML at most, I don't think it's critical to
" show symbols that may confuse parsers. I've never had such problems myself:
hi! def link htmlError NONE

