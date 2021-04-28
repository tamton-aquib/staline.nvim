local Config = require('config')

local cmd = vim.api.nvim_command
local getModeColor = require('tables').getModeColor
local modes = require('tables').modes
local getFileIcon = require('tables').getFileIcon
local lightGrey = "#303030"

local leftSeparator = Config.defaults.leftSeparator
local rightSeparator = Config.defaults.rightSeparator

-- local leftSeparator = ""	-->    
-- local rightSeparator = ""	-->    

function ifNotFound (t, d)
  local mt = {__index = function () return d end}
  setmetatable(t, mt)
end

function get_statusline()
	local mode = vim.api.nvim_get_mode()['mode']
	local extension = vim.bo.ft

	ifNotFound(modes, ' ')
	ifNotFound(getFileIcon, ' ')
	ifNotFound(getModeColor, red)

	local modeIcon	= modes[mode]
	local modeColor = getModeColor[mode]
	local fileIcon	= getFileIcon[extension]

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..leftSeparator
	s = s..'%#MidArrow#'..leftSeparator..' %M'

	s = s..'%='

	s = s..rightSeparator..'%#Arrow#'..rightSeparator..'%#Noice# '
	s = s..fileIcon..'  [%l/%L] :%c 並%p%%  '

	cmd('hi Noice guibg='..modeColor..' guifg=#000000')
	cmd('hi Arrow guifg='..modeColor..' guibg='..lightGrey)
	cmd('hi MidArrow guifg='..lightGrey)
	return s
end

return {
	setup = Config.setup,
	get_statusline = get_statusline
}
