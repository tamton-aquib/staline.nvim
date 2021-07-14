local cmd = vim.api.nvim_command

M = {}
local Tables = require('tables')

function M.set_statusline()
	for _, win in pairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_get_current_win() == win then
			vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline("active")'
		else
			vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline()'
		end
	end
end

function M.setup(opts)
	for k,_ in pairs(opts or {}) do
		for k1,v1 in pairs(opts[k]) do Tables[k][k1] = v1 end
	end
	vim.cmd [[au WinEnter,BufWinEnter,BufEnter * lua require'staline'.set_statusline()]]
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
	cmd('hi Noice guibg='..modeColor..' guifg='..fg)
	cmd('hi Arrow guifg='..modeColor..' guibg='.."#303030")
	cmd('hi MidArrow guifg='.."#303030"..' guibg='..bg)
	cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
end

function M.get_statusline(status)
	local t =  Tables.defaults

	local mode = vim.api.nvim_get_mode()['mode']
	local modeIcon = Tables.mode_icons[mode] or " "
	local modeColor = status and Tables.mode_colors[mode] or "#303030"

	local f_name = t.full_path and '%F' or '%t' -- fullpath:match("^.+/(.+)$") or ""
	local f_icon = get_file_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))

	local right_side, left_side = "%=", "%="
	local edited = vim.bo.modified and "  " or " "

	if t.filename_section == "right" then right_side = ""
	elseif t.filename_section == "left" then left_side = ""
	elseif t.filename_section == "none" then f_name, f_icon = "", ""
	elseif t.filename_section == "center" then
	else f_name, f_icon = Tables.defaults.filename_section, "" end

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..t.left_separator
	..'%#MidArrow#'..t.left_separator.." %#BranchName#"..branch_name..left_side.." "..

	f_icon.."%#BranchName# "..f_name..edited.. "%#MidArrow#"..right_side..
	"%#BranchName#"..t.cool_symbol.."%#MidArrow# "

	..t.right_separator..'%#Arrow#'..t.right_separator..'%#Noice#'.."  "..t.line_column ..' '

	call_highlights(modeColor, t.fg, t.bg)
	return s
end

return M
