" Vim's way of highlighting markdown has a special syntax-group for showing
" internal underscores in red (e.g. 'variable_name') which is done to indicate
" that this is a problem. Strictly speaking, this may indeed be an error, but
" most modern Markdown-parsers do not have any trouble dealing with these, and
" some will even literally render '\_' (which vim considers acceptable).
"
" Since the `markdownError` syntax-group only refers to this one particular
" thing, we can just turn off the highlighting for it:
hi! def link markdownError NONE
" ^ Note: Before settling on the above, I tried `syn clear markdownError`, but
" -- though arguably neater -- this is won't work because it causes italics to
"  leak everywhere.  In other words, the group is needed to prevent italics
"  from being set off by internal underscores, but should arguably just
"  display as normal text, rather than being highlighted as erroneous.
