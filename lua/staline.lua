local cmd = vim.api.nvim_command

M = {}
local Tables = require('tables')

function M.setup(opts)
	for k,_ in pairs(opts or {}) do
		for k1,v1 in pairs(opts[k]) do Tables[k][k1] = v1 end
	end

    vim.o.statusline = '%!v:lua.require\'staline\'.get_statusline()'
end

-- local function get_branch()
-- 	if not pcall(require, 'plenary') then return "" end

-- 	local branch_name = require('plenary.job'):new({
-- 		command = 'git',
-- 		args = { 'branch', '--show-current' },
-- 		on_stdout = function(_, return_val)
-- 		return return_val
-- 	  end,
-- 	}):sync()[1]
-- 	return branch_name and ' '..branch_name or ""
-- end
local branch_name = ' '..vim.trim(vim.fn.system('git branch --show-current')) or ""

local function get_file_icon(f_name, ext)
	if not pcall(require, 'nvim-web-devicons') then
		return Tables.file_icons[ext] end
	return require'nvim-web-devicons'.get_icon(f_name, ext, {default = true})
end

local function call_highlights(modeColor)
	cmd('hi Noice guibg='..modeColor..' guifg='..fg)
	cmd('hi Arrow guifg='..modeColor..' guibg='.."#303030")
	cmd('hi MidArrow guifg='.."#303030"..' guibg='..bg)
	cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
end

function M.get_statusline()

	for k, _ in pairs(Tables.defaults) do
		_G[k] = Tables.defaults[k]
	end

	local mode = vim.api.nvim_get_mode()['mode']
	local modeIcon = Tables.mode_icons[mode] or " "
	local modeColor = Tables.mode_colors[mode] or "#e27d60"

	local ext = vim.fn.expand('%:e')
	local fullpath = vim.fn.expand('%:p') or ""
	local f_name = full_path and '%F' or fullpath:match("^.+/(.+)$") or ""
	local f_icon = get_file_icon(f_name, ext)

	local right_side, left_side = "%=", "%="
	local edited = vim.bo.modified and "  " or " "

	if filename_section == "right" then right_side = ""
	elseif filename_section == "left" then left_side = ""
	elseif filename_section == "none" then f_name, f_icon = "", ""
	elseif filename_section == "center" then
	else f_name, f_icon = Tables.defaults.filename_section, "" end

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..left_separator
	..'%#MidArrow#'..left_separator.." %#BranchName#"..branch_name..

	left_side.." "..f_icon.."%#BranchName# "..f_name..edited.. "%#MidArrow#"..right_side

	..right_separator..'%#Arrow#'..right_separator..'%#Noice#'.."  "..line_column..cool_symbol ..' '

	call_highlights(modeColor)
	return s
end

return M
