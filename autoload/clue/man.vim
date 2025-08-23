func clue#man#lookup(s)
	let txt = systemlist("man 3 " . a:s)
	if len(txt) < 2
		return 0
	endif
	call clue#util#popup(txt, 'clue#dash#popup_filter')
	return 1
endfunc
