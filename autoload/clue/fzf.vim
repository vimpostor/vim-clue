let s:actions = ["ctrl-b", "ctrl-d", "ctrl-z"]

func clue#fzf#show(docs)
	let a = []
	for doc in a:docs
		let l = clue#dash#get_all(doc)
		let a = a->extend(map(l, {_, v -> v.name . "\t" . clue#dash#html_absolute_path(doc, clue#dash#sanitize_sqlite_path(v.path))}))
	endfor
	call fzf#run(fzf#wrap(#{source: a, sinklist: function('clue#fzf#sink'), options: ['--delimiter', "\t", '--with-nth', '1', '--preview', 'pandoc -w plain -r html $(printf {2} | sed "s/#.*//")', '--expect', join(s:actions, ',')]}))
endfunc

func clue#fzf#all()
	call clue#fzf#show(clue#dash#sorted_docs())
endfunc

func clue#fzf#filetype()
	call clue#fzf#show(clue#dash#priority_docs(2))
endfunc

func clue#fzf#relevant()
	if &filetype
		call clue#fzf#filetype()
	else
		call clue#fzf#all()
	endif
endfunc

func clue#fzf#sink(l)
	let k = strcharpart(a:l[0], 5)
	let t = stridx(a:l[1], "\t")
	let q = strcharpart(a:l[1], 0, t)
	let p = strcharpart(a:l[1], t + 1)
	if k == "b"
		call clue#dash#open_external(p)
	elseif k == "d" || k == "z"
		call clue#dash#query_external(q)
	elseif k == "p"
		call clue#dash#show_pandoc(p)
	else
		call clue#dash#show(p, q, g:clue_options.default_handler)
	endif
endfunc
