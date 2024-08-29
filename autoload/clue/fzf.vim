func clue#fzf#show(doc)
	let l = clue#dash#get_all(a:doc)
	let a = map(l, {_, v -> v.name . "\t" . clue#dash#html_absolute_path(a:doc, clue#dash#sanitize_sqlite_path(v.path))})
	call fzf#run(fzf#wrap(#{source: a, sink: function('clue#fzf#sink'), options: ['--delimiter', "\t", '--with-nth', '1', '--preview', 'pandoc -w plain -r html {2}']}))
endfunc

func clue#fzf#sink(s)
	call clue#dash#open_external(strcharpart(a:s, stridx(a:s, "\t") + 1))
endfunc
