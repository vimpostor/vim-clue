func clue#util#current_symbol()
	let pat = '[^A-Za-z0-9_:]'
	let n = line('.')
	let a = searchpos(pat, 'bnW', n)[1]
	let b = searchpos(pat, 'nW', n)[1] - 2
	return getbufoneline(bufnr("%"), n)[a : b]
endfunc
