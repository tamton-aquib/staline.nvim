M = {}
Tables = require('tables')

local cmd = vim.api.nvim_command

function M.setup(opts)
	if not opts then opts = {} end

	for k,v in pairs(opts) do
		for k1,v1 in pairs(opts[k]) do Tables[k][k1] = v1 end
	end

    vim.o.statusline = '%!v:lua.require\'staline\'.get_statusline()'
end

local function get_branch()
	local ok, _ = pcall(require, 'plenary')
	if not ok then return "" end

	local branch_name = require('plenary.job'):new({
		command = 'git',
		args = { 'branch', '--show-current' },
		on_stdout = function(j, return_val)
		return return_val
	  end,
	}):sync()[1]
	return branch_name and ' '..branch_name or ""
end

branch = get_branch()

local function call_highlights(modeColor)
	local lightGrey = "#303030"
	cmd('hi Noice guibg='..modeColor..' guifg='..fg)
	cmd('hi Arrow guifg='..modeColor..' guibg='..lightGrey)
	cmd('hi MidArrow guifg='..lightGrey..' guibg='..bg)
	cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
	cmd('hi DevIconLua guibg='..bg)
end

function M.get_statusline()

	for k,v in pairs(Tables.defaults) do
		_G[k] = Tables.defaults[k]
	end

	local mode = vim.api.nvim_get_mode()['mode']

	local modeIcon	= Tables.mode_icons[mode] or " "
	local modeColor = Tables.mode_colors[mode] or "#e27d60"

	local extension = vim.fn.expand('%:e')
	local fullpath = vim.fn.expand('%:p') or ""
	local f_name = full_path and fullpath or fullpath:match("^.+/(.+)$") or ""
	local f_icon, icon_highlight  = require'nvim-web-devicons'.get_icon(filename, extension, {default = true})

	local right_side = "%="
	local left_side = "%="

	if filename_position == "right" then right_side = ""
	elseif filename_position == "left" then left_side = ""
	elseif filename_position == "none" then f_name, f_icon = "", ""
	elseif filename_position == "center" then
	else f_name, f_icon = Tables.defaults.filename_position, "" end

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..leftSeparator
	..'%#MidArrow#'..leftSeparator.." %#BranchName#"..branch.. ' %M'..

	left_side..'%#DevIconLua#  '..f_icon.."%#BranchName# "..f_name.. "  %#MidArrow#"..right_side

	..rightSeparator..'%#Arrow#'..rightSeparator..'%#Noice#  '..line_column..cool_symbol ..' '

	call_highlights(modeColor)

	return s
end

return M
