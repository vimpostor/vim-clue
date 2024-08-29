let s:docs = {}
let s:popup_current_path = ""
let s:current_query = ""

func clue#dash#init()
	for p in clue#dash#docset_paths()
		if !isdirectory(p)
			continue
		endif
		for d in readdir(p)
			let dpath = p . '/' . d
			let meta = dpath . '/meta.json'
			if !filereadable(meta)
				continue
			endif

			try
				let j = json_decode(join(readfile(meta)))
				let rsc = dpath . '/Contents/Resources'
				if !filereadable(rsc . '/docSet.dsidx')
					continue
				endif

				let s:docs[j.name] = #{path: rsc}
			catch
				continue
			endtry
		endfor
	endfor
endfunc

func clue#dash#docset_paths()
	return [$HOME . '/.local/share/Zeal/Zeal/docsets', $HOME . '/Library/Application Support/Dash/DocSets']
endfunc

func clue#dash#sanitize_sqlite_path(s)
	let res = a:s
	while stridx(res, '<dash_entry_') == 0
		let res = strcharpart(res, stridx(res, '>') + 1)
	endwhile
	return res
endfunc

func clue#dash#query(doc, query)
	let res = trim(system(printf('sqlite3 -json %s "SELECT path FROM searchIndex WHERE name = %s"', s:docs[a:doc].path . '/docSet.dsidx', printf("'%s'", a:query))))
	if empty(res)
		return []
	endif
	return map(json_decode(res), {_, v -> clue#dash#sanitize_sqlite_path(v.path)})
endfunc

func clue#dash#get_all(doc)
	return json_decode(system(printf('sqlite3 -json %s "SELECT name,path FROM searchIndex"', s:docs[a:doc].path . '/docSet.dsidx')))
endfunc

func clue#dash#html_absolute_path(doc, path)
	return s:docs[a:doc].path . '/Documents/' . a:path
endfunc

func clue#dash#query_external(s)
	call system(printf("xdg-open 'dash-plugin:query=%s'", clue#util#uri_encode(a:s)))
endfunc

func clue#dash#additional_docs()
	if &filetype == "cpp"
		return ["C++", "Qt_6"]
	endif
	return []
endfunc

func clue#dash#priority_docs()
	" most relevant docsets match in an earlier level, and move to the front
	let levels = [{v -> v ==? &filetype}, {v -> index(clue#dash#additional_docs(), v) + 1}, {v -> 1}]
	let r = []
	for L in levels
		call extend(r, filter(keys(s:docs), {_, v -> index(r, v) < 0 && L(v)}))
	endfor
	return r
endfunc

func clue#dash#open(query, mode)
	let s:current_query = a:query
	for doc in clue#dash#priority_docs()
		let res = clue#dash#query(doc, a:query)
		if len(res)
			break
		endif
	endfor
	if empty(res)
		return 0
	endif

	let path = clue#dash#html_absolute_path(doc, res[0])
	if a:mode == 'term'
		call clue#dash#open_internal(path)
	elseif a:mode == 'popup'
		call clue#dash#show_pandoc(path)
	else
		call clue#dash#open_external(path)
	end
	return 1
endfunc

func clue#dash#open_internal(path)
	exec printf("term %s %s", g:clue_options.browser, a:path)
endfunc

func clue#dash#open_external(path)
	call system("xdg-open " . a:path)
endfunc

func clue#dash#lookup(query)
	if !clue#dash#open(a:query, 'popup')
		call clue#dash#query_external(a:query)
	endif
endfunc

func clue#dash#lookup_current()
	call clue#dash#lookup(clue#util#current_symbol())
endfunc

func clue#dash#lookup_visual()
	" first enter visual mode again, it got lost in the mapping and otherwise the cursor would be at the start of the selection instead of at the last location
	exec "normal! gv"
	call clue#dash#lookup(join(getregion(getpos('v'), getpos('.'), #{ type: mode() })))
endfunc

func clue#dash#show_w3m(path)
	let b = term_start(['w3m', '-o', 'confirm_qq=false', a:path], #{hidden: 1, term_finish: 'close', term_kill: 'term'})
	call popup_create(b, #{minwidth: 50, minheight: 20})
endfunc

func clue#dash#popup_filter(w, k)
	if a:k == 'b'
		call popup_close(a:w)
		call clue#dash#open_external(clue#util#strip_anchor(s:popup_current_path))
		return 1
	elseif a:k == 'd' || a:k == 'z'
		call popup_close(a:w)
		call clue#dash#query_external(s:current_query)
		return 1
	elseif a:k == 'w'
		call popup_close(a:w)
		call clue#dash#show_w3m(s:popup_current_path)
		return 1
	elseif a:k == 'x'
		call popup_close(a:w)
		return 1
	endif
	return 0
endfunc

func clue#dash#show_pandoc(path)
	" skip to anchor
	let a = clue#util#get_anchor(a:path)
	let f = clue#util#strip_anchor(a:path)
	let html = readfile(f)
	if len(a)
		while len(html) && stridx(html[0], a) == -1
			call remove(html, 0)
		endwhile
	endif
	let txt = systemlist("pandoc -w plain -r html -", html)
	let s:popup_current_path = a:path
	let w = popup_atcursor(txt, #{moved: "any", filter: 'clue#dash#popup_filter'})
	call setbufvar(winbufnr(w), '&filetype', &filetype)
endfunc

call clue#dash#init()
