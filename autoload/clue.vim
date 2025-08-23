func clue#init()
	let g:clue_options = extend(clue#default_options(), get(g:, 'clue_options', {}))

	if g:clue_options.default_mappings
		nnoremap <silent> <F1> <Cmd>call clue#lookup_current()<CR>
		xnoremap <silent> <F1> <Cmd>call clue#lookup_visual()<CR>
		nnoremap <silent> <Leader>d :call clue#fzf#relevant()<CR>
	endif
endfunc

func clue#default_options()
	return #{
		\ browser: "w3m",
		\ default_handler: "popup",
		\ default_mappings: 1,
	\ }
endfunc

func clue#lookup_current()
	call clue#lookup(clue#util#current_symbol())
endfunc

func clue#lookup_visual()
	call clue#lookup(join(getregion(getpos('v'), getpos('.'), #{ type: mode() })))
endfunc

func clue#lookup(s)
	if &filetype == "vim"
		call clue#vimscript#lookup(a:s)
		return
	elseif &filetype == "c"
		if clue#man#lookup(3, a:s)
			return
		endif
	elseif &filetype == "sh"
		if clue#man#lookup(1, a:s)
			return
		endif
	endif
	call clue#dash#lookup(a:s)
endfunc
