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
		command = 'git',
		args = { 'branch', '--show-current' },
	}):sync()[1]
	return branch_name and ' '..branch_name or ""
end
local branch_name = get_branch()

local function get_file_icon(f_name, ext)
	if not pcall(require, 'nvim-web-devicons') then
		return Tables.file_icons[ext] end
	return require'nvim-web-devicons'.get_icon(f_name, ext, {default = true})
end

local function call_highlights(modeColor, fg, bg)
	vim.cmd('hi Staline guibg='..modeColor..' guifg='..fg)
	vim.cmd('hi Arrow guifg='..modeColor..' guibg=none')
	vim.cmd('hi DoubleArrow guifg='..modeColor..' guibg=#303030')
	vim.cmd('hi MidArrow guifg='.."#303030"..' guibg='..bg)
	vim.cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
end

function M.get_statusline(status)
	M.sections = {}

	local t =  Tables.defaults
	local mode = vim.api.nvim_get_mode()['mode']
	local modeIcon = Tables.mode_icons[mode] or " "
	local modeColor = status and Tables.mode_colors[mode] or "#303030"

	local f_name = vim.fn.expand('%:t')
	local f_icon, icon_hl = get_file_icon(f_name, vim.fn.expand('%:e'))
	local edited = vim.bo.mod and "  " or " "
	local right, left = "%=", "%="

	if t.filename_section == "right" then right = ""
	elseif t.filename_section == "left" then left = ""
	elseif t.filename_section == "none" then f_name, f_icon = "", ""
	elseif t.filename_section == "center" then
	else f_name, f_icon = Tables.defaults.filename_section, "" end

	call_highlights(modeColor, t.fg, t.bg)

	local roger = special_table[vim.bo.ft]
	if status and roger then
		return "%#BranchName#%="..roger[2]..roger[1].."%="
	end

	M.sections['mode'] = '%#Staline#  '..modeIcon.." "
	M.sections['branch'] = "%#BranchName# "..branch_name.."  "
	M.sections['filename'] = "%#"..icon_hl.."#"..f_icon.."%#BranchName# "..f_name..edited.."%#MidArrow#"
	M.sections['cool_symbol'] = "%#BranchName#"..t.cool_symbol.."%#MidArrow# "
	M.sections['line_column'] = "%#Staline# "..t.line_column
	M.sections['left_sep'] = "%#Arrow#"..t.left_separator
	M.sections['right_sep'] = "%#Arrow#"..t.right_separator
	M.sections['space'] = " "
	M.sections['left_double_sep'] = "%#DoubleArrow#"..t.left_separator.."%#MidArrow#"..t.left_separator
	M.sections['right_double_sep'] = "%#MidArrow#"..t.right_separator.."%#DoubleArrow#"..t.right_separator

	if Tables.sections ~= nil then
		New_sections = {left = {}, mid = {}, right = {}}
		for _, major in pairs({ 'left', 'mid', 'right'}) do
			for _, section in pairs(Tables.sections[major] or {}) do
				table.insert(New_sections[major], M.sections[section] or ("%#BranchName#"..section))
			end
		end

		local LEFT = vim.fn.join(New_sections.left, "")
		local MID  = vim.fn.join(New_sections.mid, "")
		local RIGHT= vim.fn.join(New_sections.right, "")

		return LEFT..left..MID..right..RIGHT

	else
		local order = {
			'mode', " ", 'left_double_sep', 'branch',
			"%=", 'filename', "%=",
			'cool_symbol', 'right_double_sep', 'line_column', " "
		}
		Else_Table = {}
		for _, bruh in pairs(order) do
			table.insert(Else_Table, M.sections[bruh] or ("%#BranchName#"..bruh))
		end
		return vim.fn.join(Else_Table, "")
	end

end

return M
