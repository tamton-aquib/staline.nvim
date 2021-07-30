M = {}
local Tables = require('tables')
local special_table = {NvimTree = {'NvimTree', ' '}, packer = {'Packer',' '}, dashboard = {'Dashboard', '  '}}

function M.set_statusline()
	for _, win in pairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_get_current_win() == win then
			vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline("active")'
		else
			if vim.api.nvim_buf_get_name(0) ~= "" then
				vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline()'
			end
		end
	end
end

function M.setup(opts)
	for k,_ in pairs(opts or {}) do
		for k1,v1 in pairs(opts[k]) do Tables[k][k1] = v1 end
	end

	vim.cmd [[au BufEnter,BufWinEnter,WinEnter * lua require'staline'.set_statusline()]]
end

local function get_branch()
	if not pcall(require, 'plenary') then return "" end

	local branch_name = require('plenary.job'):new({
		command = 'git', args = { 'branch', '--show-current' },
	}):sync()[1]
	return branch_name and ' '..branch_name or ""
end
local branch = get_branch()

local function get_file_icon(f_name, ext)
	if not pcall(require, 'nvim-web-devicons') then
		return Tables.file_icons[ext] end
	return require'nvim-web-devicons'.get_icon(f_name, ext, {default = true})
end

local function call_highlights(modeColor, fg, bg)
	vim.cmd('hi Staline guibg='..modeColor..' guifg='..fg)
	vim.cmd('hi StalineNone guifg=none guibg='..bg)
	vim.cmd('hi DoubleArrow guifg='..modeColor..' guibg=#303030')
	vim.cmd('hi MidArrow guifg='.."#303030"..' guibg='..bg)
	vim.cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
end

local function get_lsp()
	local get = vim.lsp.diagnostic.get_count
	local noice = ""
	for diag, sign in pairs({Error=" ", Information=" ", Warning=" ", Hint=""}) do
		local number = get(0, diag) > 0 and " "..sign..get(0, diag) or ""
		noice = noice..number
	end

    return "%#BranchName#"..noice
end

function M.get_statusline(status)
	M.sections = {}

	local t =  Tables.defaults
	local mode = vim.api.nvim_get_mode()['mode']
	local modeColor = status and Tables.mode_colors[mode] or "#303030"

	local f_name = t.full_path and '%F' or '%t'
	local f_icon = get_file_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
	local edited = vim.bo.mod and "  " or ""

	call_highlights(modeColor, t.fg, t.bg)

	local roger = special_table[vim.bo.ft]
	if status and roger then
		return "%#BranchName#%="..roger[2]..roger[1].."%="
	end

	M.sections['mode']        = "  "..Tables.mode_icons[mode] or " ".."  "
	M.sections['branch']      = " "..branch.." "
	M.sections['filename']    = " "..f_icon.." "..f_name..edited.." "
	M.sections['cool_symbol'] = " "..t.cool_symbol.." "
	M.sections['line_column'] = " "..t.line_column.." "
	M.sections['left_sep']    = t.left_separator
	M.sections['right_sep']   = t.right_separator
	M.sections['left_sep_double']  = "%#DoubleArrow#"..t.left_separator.."%#MidArrow#"..t.left_separator
	M.sections['right_sep_double'] = "%#MidArrow#"..t.right_separator.."%#DoubleArrow#"..t.right_separator
	M.sections['lsp']         = get_lsp()

	local function check_section(section)
		if string.match(section, "^-") then
			local section = section:match("^-(.+)")
			return "%#Staline#"..(M.sections[section] or section)
		else
			return "%#BranchName#"..(M.sections[section] or section)
		end
	end

	local staline = {left = {}, mid = {}, right = {}}
	for _, major in pairs({ 'left', 'mid', 'right'}) do
		for _, section in pairs(Tables.sections[major]) do
			table.insert(staline[major], check_section(section).."%#StalineNone#")
		end
	end

	local LEFT  = vim.fn.join(staline.left , "")
	local MID   = vim.fn.join(staline.mid  , "")
	local RIGHT = vim.fn.join(staline.right, "")

	return LEFT.."%="..MID.."%="..RIGHT
end

return M
