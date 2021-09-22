local Stabline = {}
local cmd = vim.api.nvim_command

local type_chars={ bar={left="┃", right=" "}, slant={left="", right=""}, arrow={left="", right=""}, bubble={left="", right=""} }
-- NOTE: options: inactive_fg, inactive_bg, fg, bg, start, style, stab_left, stab_right, font_active, font_inactive, stab_bg

local normal_bg = vim.api.nvim_get_hl_by_name("Normal", {})['background'] or 255
local normal_fg = vim.api.nvim_get_hl_by_name("Normal", {})['foreground'] or 0

function Stabline.setup(opts)
	Stabline.stabline_opts =  opts or {style = "bar"}
	vim.tbl_deep_extend('force', Stabline.stabline_opts, opts or {})

	vim.cmd [[au BufEnter * lua require"stabline".call_stabline_colors()]]
	vim.o.tabline = '%!v:lua.require\'stabline\'.get_tabline()'
end

function Stabline.call_stabline_colors()
	local opts = Stabline.stabline_opts
	local stab_type = opts.style or "bar"
	local bg_hex = opts.bg or string.format("#%x", normal_bg)
	local fg_hex = opts.fg or string.format("#%x", normal_fg)
	local dark_bg = opts.stab_bg or string.format("#%x", normal_bg/2)
	local inactive_bg, inactive_fg = opts.inactive_bg or "#1e2127", opts.inactive_fg or "#aaaaaa"
	local set, set_inactive = {}, {}

	if stab_type == "bar" then
		set = { left = {f = fg_hex, b = bg_hex}, right = {f = fg_hex, b = bg_hex} }
		set_inactive = { left = {f = inactive_bg, b = inactive_bg}, right = {f = fg_hex, b = inactive_bg} }
	elseif stab_type == "slant" then
		set = { left = {f = bg_hex, b = dark_bg}, right = {f = bg_hex, b = dark_bg} }
		set_inactive = { left = {f = inactive_bg, b = dark_bg}, right = {f = inactive_bg, b = dark_bg} }
	elseif stab_type == "arrow" then
		set = { left = {f = dark_bg, b = bg_hex}, right = {f = bg_hex, b = dark_bg} }
		set_inactive = { left = {f = dark_bg, b = inactive_bg}, right = {f = inactive_bg, b = dark_bg} }
	elseif stab_type == "bubble" then
		set = { left = {f = bg_hex, b = dark_bg}, right = {f = bg_hex, b = dark_bg} }
		set_inactive = { left = {f = inactive_bg, b = dark_bg}, right = {f = inactive_bg, b = dark_bg} }
	end

	cmd('hi StablineSel guifg='..fg_hex..' guibg='..bg_hex..' gui='..(opts.font_active or 'bold'))
	cmd('hi Stabline guibg='..dark_bg)
	cmd('hi StablineLeft guifg='..set.left.f..' guibg='..set.left.b)
	cmd('hi StablineRight guifg='..set.right.f..' guibg='..set.right.b)
	cmd('hi StablineInactive guifg='..inactive_fg..' guibg='..inactive_bg..' gui='..(opts.font_inactive or 'none'))
	cmd('hi StablineInactiveRight guifg='..set_inactive.right.f..' guibg='..set_inactive.right.b)
	cmd('hi StablineInactiveLeft guifg='..set_inactive.left.f..' guibg='..set_inactive.left.b)
end

local function get_file_icon(f_name, ext)
	if not pcall(require, 'nvim-web-devicons') then
		return require'tables'.file_icons[ext] or " " end
	return require'nvim-web-devicons'.get_icon(f_name, ext, {default = true})
end

local function do_icon_hl(icon_hl)
	local new_fg = string.format("#%x",vim.api.nvim_get_hl_by_name(icon_hl or 'Normal', {})['foreground'] or 0)
	local icon_bg = Stabline.stabline_opts.bg or string.format("#%x", normal_bg)
	cmd('hi StablineTempHighlight guibg='..icon_bg..' guifg='..new_fg..' gui=bold')
	return '%#StablineTempHighlight#'
end

function Stabline.get_tabline()
	local opts = Stabline.stabline_opts
	local exclude_fts = opts.exclude_fts or {'NvimTree', 'help', 'dashboard', 'lir'}
	local stab_type = opts.style or "bar"
	local stab_left = opts.stab_left or type_chars[stab_type].left
	local stab_right= opts.stab_right or type_chars[stab_type].right
	local tabline = opts.stab_start and ("%#Stabline#"..opts.stab_start) or "%#Stabline#"

	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
			local edited = vim.bo.modified and "" or " "

			local f_name = vim.api.nvim_buf_get_name(buf):match("^.+/(.+)$") or ""
			local ext = string.match(f_name, "%w+%.(.+)")
			local f_icon, icon_hl = get_file_icon(f_name, ext)

			if vim.tbl_contains(exclude_fts, vim.bo[buf].ft) or f_name == "" then
				goto do_nothing
			else
				f_name = " ".. f_name .." "
			end

			local s = vim.api.nvim_get_current_buf() == buf and true or false

			tabline = tabline..
			"%#Stabline"..(s and "" or "Inactive").."Left#"..stab_left..
			"%#Stabline"..(s and "Sel" or "Inactive").."#   "..
			(s and do_icon_hl(icon_hl) or "")..f_icon..
			"%#Stabline"..(s and "Sel" or "Inactive").."#"..f_name.." "..(s and edited or " ")..
			"%#Stabline"..(s and "" or "Inactive").."Right#"..stab_right
		end
		::do_nothing::
	end

	return tabline.."%#Stabline#%="..(opts.stab_end or "")
end

return Stabline
