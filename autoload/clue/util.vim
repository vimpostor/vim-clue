let s:last_popup = 0

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

func clue#util#get_anchor(u)
	let h = stridx(a:u, '#')
	return h == -1 ? "" : strcharpart(a:u, h + 1)
endfunc

func clue#util#strip_anchor(u)
	let a = len(clue#util#get_anchor(a:u))
	return strcharpart(a:u, 0, len(a:u) - a - !!a)
endfunc

func clue#util#popup(txt, filter)
	let tcols = 80
	if has('nvim')
		let buf = nvim_create_buf(0, 1)
		call nvim_buf_set_lines(buf, 0, -1, 1, a:txt)
		let s:last_popup = nvim_open_win(buf, 0, #{relative: 'cursor', bufpos: getpos('.')[1:2], width: tcols, height: 50, style: 'minimal'})
		au CursorMoved * ++once call nvim_win_close(s:last_popup, 1)
	else
		let o = #{moved: "any", minwidth: tcols}
		if len(a:filter)
			let o.filter = a:filter
		endif
		let s:last_popup = popup_atcursor(a:txt, o)
	endif
	call setbufvar(winbufnr(s:last_popup), '&syntax', len(&syntax) ? &syntax : 'markdown')
endfunc

func clue#util#choose(arr, callback)
	if len(a:arr) == 1
		" no need to choose
		call function(a:callback)(-1, 1)
		return
	endif

	if has('nvim')
		let buf = nvim_create_buf(0, 1)
		call nvim_buf_set_lines(buf, 0, -1, 1, a:arr)
		let win = nvim_open_win(buf, 1, #{relative: "cursor", bufpos: getpos('.')[1:2], width: len(a:arr[0]), height: len(a:arr), style: "minimal"})
		call nvim_buf_set_keymap(buf, "n", "<CR>", ':let a = line(".")<CR>:close<CR>:call ' . a:callback . '(-1, a)<CR>', #{})
	else
		call popup_menu(a:arr, #{callback: a:callback})
	endif
endfunc
