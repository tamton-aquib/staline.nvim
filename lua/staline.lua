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

local lightGrey = "#303030"

function get_branch()
	local ok, nice = pcall(require, "plenary")
	if not ok then return "" end

	local branch = require('plenary.job'):new({
		command = 'git',
		args = { 'describe', '--contains', '--all', 'HEAD' },
		on_stdout = function(j, return_val)
		return return_val
	  end,
	}):sync()[1]
	return branch and ' '..branch or ""
end

local branch = get_branch('plenary')

function call_highlights(modeColor)
	cmd('hi Noice guibg='..modeColor..' guifg='..fg)
	cmd('hi Arrow guifg='..modeColor..' guibg='..lightGrey)
	cmd('hi MidArrow guifg='..lightGrey..' guibg='..bg)
	cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
end

function M.get_statusline()

	for k,v in pairs(Tables.defaults) do
		_G[k] = Tables.defaults[k]
	end

	local mode = vim.api.nvim_get_mode()['mode']
	local extension = vim.fn.expand('%:e')
	local fullpath = vim.fn.expand('%:p') or ""
	local filename = full_path and fullpath or fullpath:match("^.+/(.+)$") or ""
	local right_side = "%="
	local left_side = "%="

	local modeIcon	= Tables.mode_icons[mode] or " "
	local modeColor = Tables.mode_colors[mode] or "#e27d60"
	local fileIcon, icon_highlight  = require'nvim-web-devicons'.get_icon(filename, extension, {default = true})

    if filename_position == "right" then right_side = ""
    elseif filename_position == "left" then left_side = ""
    elseif filename_position == "none" then filename, fileIcon = "", ""
    else filename_position = "center" end

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..leftSeparator
	s = s..'%#MidArrow#'..leftSeparator.." %#BranchName#"..branch.. ' %M'

	s = s..left_side
	s = s..'%#'..icon_highlight..'#  '..fileIcon.."%#BranchName#"..' '..filename.. "  %#MidArrow#"
	s = s..right_side

	s = s..rightSeparator..'%#Arrow#'..rightSeparator..'%#Noice#  '..line_column..cool_symbol ..' '

	call_highlights(modeColor)

	return s
end

return M
