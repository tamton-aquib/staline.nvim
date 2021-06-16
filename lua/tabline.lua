local vim = vim
local cmd = vim.api.nvim_command

local function call_tabline_colors()
	local normal_bg = vim.api.nvim_get_hl_by_name("Normal", {})['background'] or 255
	local normal_fg = vim.api.nvim_get_hl_by_name("Normal", {})['foreground'] or 0
	local bg_hex = stabline_opts.bg or string.format("%x", normal_bg)
	local fg_hex = stabline_opts.fg or string.format("%x", normal_fg)

	cmd('hi StablineLeft gui=bold guifg='..fg_hex..' guibg='..bg_hex)
	-- cmd('hi Stabline guibg=#232433')
	cmd('hi StablineSel guifg='..fg_hex..' guibg='..bg_hex)
	cmd('hi StablineRight gui=bold guifg='..bg_hex..' guibg='..fg_hex)

end

function Get_tabline()
	local stab_left = stabline_opts.stab_left or "|"
	local stab_right = stabline_opts.stab_right or "|"
	local tabline = ""

	for i, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
			local edited = vim.bo.modified and "" or ""
			local f_name = vim.api.nvim_buf_get_name(buf):match(".*%/(.+)")
			if f_name ~= nil then f_name = "  "..f_name.."  " else f_name = "" end

			if vim.api.nvim_get_current_buf() == buf then
				if i == 1 and stab_left ~= "|" then stab_left = " " end
				tabline = tabline..
				"%#StablineLeft#"..stab_left..
				"%#StablineSel#"..f_name..edited.." "..
				"%#StablineRight#"..stab_right
			else
				tabline = tabline..
				"%#StablineFill# "..f_name..
				" %#StablineFill#"
			end
		end
	end

	call_tabline_colors()
	return tabline.."%#StablineFill#"
end

return {Get_tabline = Get_tabline}

