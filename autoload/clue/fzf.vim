let s:actions = ["ctrl-b", "ctrl-d", "ctrl-z"]

func clue#fzf#show(doc)
	let l = clue#dash#get_all(a:doc)
	let a = map(l, {_, v -> v.name . "\t" . clue#dash#html_absolute_path(a:doc, clue#dash#sanitize_sqlite_path(v.path))})
	call fzf#run(fzf#wrap(#{source: a, sinklist: function('clue#fzf#sink'), options: ['--delimiter', "\t", '--with-nth', '1', '--preview', 'pandoc -w plain -r html {2}', '--expect', join(s:actions, ',')]}))
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
	else
		call clue#dash#show_pandoc(p)
	endif
endfunc
