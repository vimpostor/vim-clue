func clue#init()
	let g:clue_options = extend(clue#default_options(), get(g:, 'clue_options', {}))

	if g:clue_options.default_mappings
		noremap <silent> <F1> :call clue#dash#lookup_current()<CR>
		xnoremap <silent> <F1> :call clue#dash#lookup_visual()<CR>
		noremap <silent> <Leader>d :call clue#fzf#filetype()<CR>
	endif
endfunc

func clue#default_options()
	return #{
		\ browser: "w3m",
		\ default_mappings: 1,
	\ }
endfunc
