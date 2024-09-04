func clue#debug#program_version(p)
	return get(systemlist(a:p . ' --version'), 0, "")
endfunc

func clue#debug#redact_home(p)
	return substitute(a:p, $HOME, '~', '')
endfunc

func clue#debug#redact_docs(d)
	return mapnew(a:d, {_, v -> extendnew(v, #{path: clue#debug#redact_home(v.path)})})
endfunc

func clue#debug#info()
	return #{pandoc: clue#debug#program_version('pandoc'), sqlite: clue#debug#program_version('sqlite3'), zeal: clue#debug#program_version('zeal'), dash_docs: clue#debug#redact_docs(clue#dash#docs()), shell: &shell}
endfunc
