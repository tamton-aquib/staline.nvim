local vim = vim
local cmd = vim.api.nvim_command
Stabline = {}

local type_chars={
	bar = {left="┃", right=" "},
	slant = {left="", right=""},
	arrow = {left="", right=""},
	bubble = {left="", right=""}
}

function Stabline.setup(opts)
	_G.stabline_opts =  opts or {style = "bar"}
	for k, v in pairs(opts) do
		stabline_opts[k] = v
	end
	vim.o.tabline = '%!v:lua.require\'stabline\'.get_tabline()'
end

local function call_tabline_colors()
	local stab_type = stabline_opts.style or "bar"

	local normal_bg = vim.api.nvim_get_hl_by_name("Normal", {})['background'] or 255
	local normal_fg = vim.api.nvim_get_hl_by_name("Normal", {})['foreground'] or 0
	local bg_hex = stabline_opts.bg or string.format("%x", normal_bg)
	local fg_hex = stabline_opts.fg or string.format("%x", normal_fg)

	local dark_bg = string.format("%x", normal_bg/2)

	cmd('hi StablineSel guifg='..fg_hex..' guibg='..bg_hex)
	cmd('hi Stabline guibg=#'..dark_bg)

	if stab_type == "bar" then
		cmd('hi StablineLeft gui=bold guifg='..fg_hex..' guibg='..bg_hex)
		cmd('hi StablineRight gui=bold guifg='..fg_hex..' guibg='..bg_hex)
	elseif stab_type == "slant" then
		cmd('hi StablineLeft guifg=#'..bg_hex..' guibg=#'..dark_bg)
		cmd('hi StablineRight guifg=#'..bg_hex..' guibg=#'..dark_bg)
	elseif stab_type == "arrow" then
		cmd('hi StablineLeft guifg=#'..dark_bg..' guibg='..bg_hex)
		cmd('hi StablineRight guifg=#'..bg_hex..' guibg=#'..dark_bg)
	elseif stab_type == "bubble" then
		cmd('hi StablineLeft guifg=#'..bg_hex..' guibg=#'..dark_bg)
		cmd('hi StablineRight guifg=#'..bg_hex..' guibg=#'..dark_bg)
	end

end

local function get_file_icon(f_name, ext)
	if not pcall(require, 'nvim-web-devicons') then
		return require'tables'.file_icons[ext] end
	return require'nvim-web-devicons'.get_icon(f_name, ext, {default = true})
end

function Stabline.get_tabline()
	local stab_type = stabline_opts.style or "bar"
	local stab_left = stabline_opts.stab_left or type_chars[stab_type].left
	local stab_right = stabline_opts.stab_right or  type_chars[stab_type].right
	local tabline = ""

	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
			local edited = vim.bo.modified and "" or ""

			local f_name = vim.api.nvim_buf_get_name(buf):match("^.+/(.+)$") or ""
			local ext = string.match(f_name, "%w+%.(.+)")
			local f_icon, icon_highlight = get_file_icon(f_name, ext)

			if f_name ~= nil then
				f_name = " "..f_name.."  "
			else
				f_name = ""
			end

			if vim.api.nvim_get_current_buf() == buf then
				if buf == 1 and stab_type == "arrow" then stab_left = " " end
				tabline = tabline..
				"%#Stabline#"..
				"%#StablineLeft#"..stab_left..
				"%#StablineSel# "..
				'%#'..icon_highlight..'#'..f_icon..
				"%#StablineSel#"..f_name..edited..
				"%#StablineRight#"..stab_right
			else
				tabline = tabline.."%#Stabline#  "..
				f_icon..f_name..
				" %#Stabline#"
			end
		end
	end

	call_tabline_colors()
	return tabline.."%#Stabline#"
end

return Stabline

