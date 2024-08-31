func clue#debug#program_version(p)
	return get(systemlist(a:p . ' --version'), 0, "")
endfunc

func clue#debug#info()
	return #{pandoc: clue#debug#program_version('pandoc'), sqlite: clue#debug#program_version('sqlite3'), dash_docs: clue#dash#docs()}
endfunc
