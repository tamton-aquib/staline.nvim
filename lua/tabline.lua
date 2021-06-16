local vim = vim
local cmd = vim.api.nvim_command

local type_chars={
	bar = {left="┃", right=" "},
	slant = {left="", right=""},
	arrow = {left="", right=""},
	bubble = {left="", right=""}
}


local function call_tabline_colors(stabline_type)

	local normal_bg = vim.api.nvim_get_hl_by_name("Normal", {})['background'] or 255
	local normal_fg = vim.api.nvim_get_hl_by_name("Normal", {})['foreground'] or 0
	local bg_hex = stabline_opts.bg or string.format("%x", normal_bg)
	local fg_hex = stabline_opts.fg or string.format("%x", normal_fg)

	local dark_bg = string.format("%x", normal_bg/2)

	cmd('hi StablineSel guifg='..fg_hex..' guibg='..bg_hex)
	cmd('hi Stabline guibg=#'..dark_bg)

	if stabline_type == "bar" then
		cmd('hi StablineLeft gui=bold guifg='..fg_hex..' guibg='..bg_hex)
		cmd('hi StablineRight gui=bold guifg='..fg_hex..' guibg='..bg_hex)
	elseif stabline_type == "slant" then
		cmd('hi StablineLeft guifg=#'..bg_hex..' guibg=#'..dark_bg)
		cmd('hi StablineRight guifg=#'..bg_hex..' guibg=#'..dark_bg)
	elseif stabline_type == "arrow" then
		cmd('hi StablineLeft guifg=#'..dark_bg..' guibg='..bg_hex)
		cmd('hi StablineRight guifg=#'..bg_hex..' guibg=#'..dark_bg)
	end

end

function Get_tabline()
	local stab_left = stabline_opts.stab_left or type_chars[stabline_opts.type].left
	local stab_right = stabline_opts.stab_right or type_chars[stabline_opts.type].right
	local stabline_type = stabline_opts.type
	local tabline = ""

	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
			local edited = vim.bo.modified and "" or " "
			local f_name = vim.api.nvim_buf_get_name(buf):match(".*%/(.+)")
			if f_name ~= nil then f_name = "   "..f_name.."  " else f_name = "" end

			if vim.api.nvim_get_current_buf() == buf then
				tabline = tabline..
				"%#StablineLeft#"..stab_left..
				"%#StablineSel#"..f_name..edited..
				"%#StablineRight#"..stab_right
			else
				tabline = tabline..
				"%#Stabline# "..f_name..
				" %#Stabline#"
			end
		end
	end

	call_tabline_colors(stabline_type)
	return tabline.."%#Stabline#"
end

return {Get_tabline = Get_tabline}

