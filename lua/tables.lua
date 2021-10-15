local Tables = {}

local function system_icon()
	if vim.fn.has("win32")    == 1 then return "者"
	elseif vim.fn.has("mac")  == 1 then return " "
	elseif vim.fn.has("unix") == 1 then return " "
	end
end

Tables = {
	sections = {
		left = { '- ', '-mode', 'left_sep_double', ' ', 'branch' },
		mid  = {'file_name'},
		right = { 'cool_symbol','right_sep_double', '-line_column' }
	},

	lsp_symbols = { Error=" ", Info=" ", Warn=" ", Hint="" },

	defaults = {
		left_separator = "",
		right_separator = "",
		line_column = " [%l/%L] :%c 並%p%% ",
		cool_symbol = system_icon(),
		fg = "#000000",
		bg = "none",
		full_path = false,
		branch_symbol = " ",
		inactive_color = "#303030",
		inactive_bgcolor = "none",
		font_active = "none",          -- bold,italic etc.
		true_colors = false,
		lsp_client_symbol = " "
	},

	special_table = {
		NvimTree = { 'NvimTree', ' ' },
		packer = { 'Packer',' ' },
		dashboard = { 'Dashboard', '  ' },
		help = { 'Help', '龎' },
		qf = { "QuickFix", " " }
	},

	mode_colors = {
		['n']    =  "#2bbb4f", --> "#6ed57e"
		['v']    =  "#4799eb",
		['V']    =  "#4799eb",
		['i']    =  "#986fec",
		['ic']   =  "#986fec",
		['s']    =  "#986fec",
		['S']    =  "#986fec",
		['c']    =  "#e27d60",
		['t']    =  "#ffd55b", --> "#" fff94c
		['r']    =  "#fff94c",
		['R']    =  "#fff94c",
		['']   =  "#4799eb"
	},

	mode_icons = {
		['n']    = ' ',
		['no']   = ' ',
		['nov']  = ' ',
		['noV']  = ' ',
		['no'] = ' ',
		['niI']  = ' ',
		['niR']  = ' ',
		['niV']  = ' ',

		['i']   = ' ',
		['ic']  = ' ',
		['ix']  = ' ',
		['s']   = ' ',
		['S']   = ' ',

		['v']   = ' ',
		['V']   = ' ',
		['']  = ' ',
		['r']   = '﯒ ',
		['r?']  = ' ',
		['c']   = ' ',
		['t']   = ' ',
		['!']   = ' ',
		['R']   = ' ',
	},

	file_icons = {
		typescript         = ' ' ,
		python             = ' ' ,
		java               = ' ' ,
		html               = ' ' ,
		css                = ' ' ,
		scss               = ' ' ,
		javascript         = ' ' ,
		javascriptreact    = ' ' ,
		markdown           = ' ' ,
		sh                 = ' ',
		zsh                = ' ',
		vim                = ' ',
		rust               = ' ',
		cpp                = ' ',
		c                  = ' ',
		go                 = ' ',
		lua                = ' ',
		conf               = ' ',
		haskel             = ' ',
		ruby               = ' ',
		txt                = ' '
	}
}

return Tables
