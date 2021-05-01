local Config = require('config')

local cmd = vim.api.nvim_command
local getModeColor = require('tables').getModeColor
local modes = require('tables').modes
local getFileIcon = require('tables').getFileIcon

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

function ifNotFound (t, d)
  local mt = {__index = function () return d end}
  setmetatable(t, mt)
end

function get_statusline()
    local leftSeparator = Config.defaults.leftSeparator
    local rightSeparator = Config.defaults.rightSeparator
    local cool_symbol = Config.defaults.cool_symbol

	local mode = vim.api.nvim_get_mode()['mode']
	local extension = vim.bo.ft

	ifNotFound(modes, ' ')
	ifNotFound(getFileIcon, ' ')
	ifNotFound(getModeColor, red)

	local modeIcon	= modes[mode]
	local modeColor = getModeColor[mode]
	local fileIcon	= getFileIcon[extension]

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..leftSeparator
	s = s..'%#MidArrow#'..leftSeparator
	s = s.." %#BranchName#"..branch.. ' %M'.. "%#MidArrow#"

    s = s..'%='

    s = s..rightSeparator..'%#Arrow#'..rightSeparator..'%#Noice# '
    s = s..fileIcon..'  [%l/%L] :%c 並%p%% '.. cool_symbol ..' '

	cmd('hi Noice guibg='..modeColor..' guifg=#000000')
	cmd('hi Arrow guifg='..modeColor..' guibg='..lightGrey)
	cmd('hi MidArrow guifg='..lightGrey)
	cmd('hi BranchName guifg='..modeColor)
	return s
end

return {
	setup = Config.setup,
	get_statusline = get_statusline
}
