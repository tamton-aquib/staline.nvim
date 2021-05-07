Config = {}

local green     = "#2bbb4f"	--> "#6ed57e"
local violet    = "#986fec"
local blue      = "#4799eb"	--> "#03353e"
local yellow    = "#fff94c"	--> "#ffd55b"
local black     = "#000000"
local red       = "#e27d60"

function system_icon()
	if vim.fn.has("win32") == 1 then return "者"
	elseif vim.fn.has("unix") == 1 then return " "
	elseif vim.fn.has("mac") == 1 then return " "
	end
end

Config.defaults = {
    leftSeparator = "",
    rightSeparator = "",
	cool_symbol = system_icon()
}

Config.getModeColor = {
     ['n']    =  green,
     ['v']    =  blue,
     ['V']    =  blue,
     ['i']    =  violet,
     ['ic']   =  violet,
     ['c']    =  red,
     ['t']    =  yellow,
     ['r']    =  yellow,
     ['R']    =  yellow
}

function Config.setup(opts)
	if not opts.defaults then opts.defaults = Config.defaults end
	if not opts.getModeColor then opts.getModeColor = Config.getModeColor end

	for k, v in pairs(opts.defaults) do Config.defaults[k] = v end
	for k, v in pairs(opts.getModeColor) do Config.getModeColor[k] = v end
    vim.o.statusline = '%!v:lua.require\'staline\'.get_statusline()'
end

local cmd = vim.api.nvim_command
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
	ifNotFound(Config.getModeColor, red)

	local modeIcon	= modes[mode]
	local modeColor = Config.getModeColor[mode]
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
