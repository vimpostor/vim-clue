func clue#man#lookup(n, s)
	let txt = systemlist(printf("man %d %s", a:n, a:s))
	if len(txt) < 2
		return 0
	endif
	call clue#util#popup(txt, 'clue#dash#popup_filter')
	return 1
endfunc
