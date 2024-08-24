func clue#util#uri_encode(s)
	return a:s->map({_, v -> 1 + match(v, '[-_.~a-zA-Z0-9]') ? v : printf("%%%02x", char2nr(v))})
endfunc

func clue#util#current_symbol()
	let pat = '[^A-Za-z0-9_:]'
	let n = line('.')
	let a = searchpos(pat, 'bnW', n)[1]
	let b = searchpos(pat, 'nW', n)[1] - 2
	return getbufoneline(bufnr("%"), n)[a : b]
endfunc
