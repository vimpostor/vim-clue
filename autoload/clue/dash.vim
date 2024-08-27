let s:docs = {}

func clue#dash#init()
	for p in clue#dash#docset_paths()
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
	return [$HOME . '/.local/share/Zeal/Zeal/docsets']
endfunc

func clue#dash#query(doc, query)
	let res = trim(system(printf('sqlite3 -json %s "SELECT path FROM searchIndex WHERE name = %s"', s:docs[a:doc].path . '/docSet.dsidx', printf("'%s'", a:query))))
	if empty(res)
		return []
	endif
	return map(json_decode(res), {_, v -> v.path})
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

func clue#dash#open(query, mode)
	for doc in keys(s:docs)
		let res = clue#dash#query(doc, a:query)
		if len(res)
			break
		endif
	endfor
	if empty(res)
		echoe "No results"
		return
	endif

	let path = clue#dash#html_absolute_path(doc, res[0])
	if a:mode == 'term'
		call clue#dash#open_internal(path)
	elseif a:mode == 'popup'
		call clue#dash#show_w3m(path)
	else
		call clue#dash#open_external(path)
	end
endfunc

func clue#dash#open_internal(path)
	exec printf("term %s %s", g:clue_options.browser, a:path)
endfunc

func clue#dash#open_external(path)
	call system("xdg-open " . a:path)
endfunc

func clue#dash#lookup(query)
	call clue#dash#query_external(a:query)
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

call clue#dash#init()
