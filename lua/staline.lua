Config = {}

function system_icon()
	if vim.fn.has("win32") == 1 then return "者"
	elseif vim.fn.has("unix") == 1 then return " "
	elseif vim.fn.has("mac") == 1 then return " "
	end
end

Config.defaults = {
	leftSeparator = "",
	rightSeparator = "",
	line_column = "[%l/%L] :%c 並%p%% ",
	cool_symbol = system_icon(),
	fg = "#000000",
	bg = "none"
}

Config.getModeColor = {
     ['n']    =  "#2bbb4f", --> "#6ed57e"
     ['v']    =  "#4799eb",
     ['V']    =  "#4799eb",
     ['i']    =  "#986fec",
     ['ic']   =  "#986fec",
     ['c']    =  "#e27d60",
     ['t']    =  "#fff94c", --> "#ffd55b"
     ['r']    =  "#fff94c",
     ['R']    =  "#fff94c"
}

Config.modes = {
     ['n']   = ' ',
     ['v']   = ' ',
     ['V']   = ' ',
     ['i']   = ' ',
     ['ic']  = '',
     ['c']   = ' ',
     ['r']   = 'Prompt',
     ['t']   = 'T',
     ['R']   = ' ',
     ['^V']  = ' '
}

function setup(opts)
	if not opts then opts = {} end

	for k,v in pairs(opts) do
		for k1,v1 in pairs(opts[k]) do
			Config[k][k1] = v1
		end
	end

    vim.o.statusline = '%!v:lua.require\'staline\'.get_statusline()'
end

local cmd = vim.api.nvim_command
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

function call_highlights(modeColor)
    local fg = Config.defaults.fg
	cmd('hi Noice guibg='..modeColor..' guifg='..fg)
	cmd('hi Arrow guifg='..modeColor..' guibg='..lightGrey)
	cmd('hi MidArrow guifg='..lightGrey..' guibg='..bg)
	cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
end

function get_statusline()

	for k,v in pairs(Config.defaults) do
		_G[k] = Config.defaults[k]
	end

	local mode = vim.api.nvim_get_mode()['mode']
	local extension = vim.bo.ft

	ifNotFound(Config.modes, ' ')
	ifNotFound(getFileIcon, ' ')
	ifNotFound(Config.getModeColor, red)

	local modeIcon	= Config.modes[mode]
	local modeColor = Config.getModeColor[mode]
	local fileIcon	= getFileIcon[extension]

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..leftSeparator
	s = s..'%#MidArrow#'..leftSeparator
	s = s.." %#BranchName#"..branch.. ' %M'.. "%#MidArrow#"

	s = s..'%='

	s = s..rightSeparator..'%#Arrow#'..rightSeparator..'%#Noice# '
	s = s..fileIcon..'  '..line_column.. cool_symbol ..' '

	call_highlights(modeColor)

	return s
end

return {
	setup = setup,
	get_statusline = get_statusline
}
