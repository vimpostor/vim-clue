local M = {}

M.check = function()
	vim.health.start("clue report")
	local info = vim.fn['clue#debug#info']()

	local ndocs = vim.tbl_count(info.dash_docs)
	if ndocs > 0 then
		vim.health.ok(string.format("Found %d dash docsets. List them with :echom clue#dash#docs()", ndocs))
	else
		vim.health.warn("No dash docsets found. Did you install any from Zeal?")
	end
end

return M
