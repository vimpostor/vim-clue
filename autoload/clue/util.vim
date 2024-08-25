func clue#util#uri_encode(s)
	return a:s->map({_, v -> match(v, '[-_.~a-zA-Z0-9]') ? printf("%%%02X", char2nr(v)) : v})
endfunc

func clue#util#current_symbol()
	let pat = '[^A-Za-z0-9_:]'
	let n = line('.')
	let a = searchpos(pat, 'bnW', n)[1]
	let b = max([-1, searchpos(pat, 'nW', n)[1] - 2])
	return getbufoneline(bufnr("%"), n)[a : b]
endfunc
