" quote-then-openbrace wraps selection in two braces:
vnoremap "{ <Esc>`<i{{<Esc>`>a<Right><Right>}}<Esc>
" quote-then-quote-then-openbrace wraps selection in two braces within outer
" quotes:
vnoremap ""{ <Esc>`<i"{{<Esc>`>a<Right><Right><Right>}}"<Esc>

