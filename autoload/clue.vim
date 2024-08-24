func clue#init()
	let g:clue_options = extend(clue#default_options(), get(g:, 'clue_options', {}))

	noremap <silent> <F1> :call clue#dash#lookup_current()<CR>
endfunc

func clue#default_options()
	return #{
		\ browser: "w3m",
	\ }
endfunc
