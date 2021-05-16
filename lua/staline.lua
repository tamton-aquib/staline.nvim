Config = {}
M = {}
Tables = require('tables')

local cmd = vim.api.nvim_command
Config.defaults = Tables.defaults
Config.getFileIcon = Tables.getFileIcon
Config.mode_colors = Tables.mode_colors
Config.mode_icons = Tables.mode_icons

function M.setup(opts)
	if not opts then opts = {} end

	for k,v in pairs(opts) do
		for k1,v1 in pairs(opts[k]) do
			Config[k][k1] = v1
		end
	end

    vim.o.statusline = '%!v:lua.require\'staline\'.get_statusline()'
end

local lightGrey = "#303030"

function has_plenary(module)
    local function requiref(module)
		local Job = require'plenary.job'
		branch = Job:new({
			command = 'git',
			args = { 'describe', '--contains', '--all', 'HEAD' },
			on_stdout = function(j, return_val)
			return return_val
		  end,
		}):sync()[1]
		branch = branch and ' '..branch or ""
    end
    res = pcall(requiref,module)
    if not(res) then
		branch = " "
    end
end
has_plenary('plenary')

function call_highlights(modeColor)
	cmd('hi Noice guibg='..modeColor..' guifg='..fg)
	cmd('hi Arrow guifg='..modeColor..' guibg='..lightGrey)
	cmd('hi MidArrow guifg='..lightGrey..' guibg='..bg)
	cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
end

function M.get_statusline()

	for k,v in pairs(Config.defaults) do
		_G[k] = Config.defaults[k]
	end

	local mode = vim.api.nvim_get_mode()['mode']
	local extension = vim.fn.expand('%:e')
	local filename = vim.fn.expand('%:t')

	local modeIcon	= Config.mode_icons[mode] or " "
	local modeColor = Config.mode_colors[mode] or "#e27d60"
    local fileIcon, icon_highlight  = require'nvim-web-devicons'.get_icon(filename, extension, {default = true})

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..leftSeparator
	s = s..'%#MidArrow#'..leftSeparator
	s = s.." %#BranchName#"..branch.. ' %M'

	s = s..'%='

	s = s..'%#'..icon_highlight..'#'..fileIcon..' '.. "%#MidArrow#"
	s = s..rightSeparator..'%#Arrow#'..rightSeparator..'%#Noice#  '..line_column..cool_symbol ..' '

	call_highlights(modeColor, fg)

	return s
end

return M
