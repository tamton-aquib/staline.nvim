
local function call_tabline_colors()
	local normal_bg = vim.api.nvim_get_hl_by_name("Normal", {})['background'] or 255
	local normal_fg = vim.api.nvim_get_hl_by_name("Normal", {})['foreground'] or 0
	local normal_bg_hex = string.format("%x", normal_bg)
	local normal_fg_hex = string.format("%x", normal_fg)

	vim.cmd('hi StablineLeft guifg='..normal_fg_hex..' guibg='..normal_bg_hex..' gui=bold')
	vim.cmd('hi TablineSel guifg=white guibg='..normal_bg_hex)
end

function get_tabline()
	local tabline = ""

	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
			local edited = vim.bo.modified and "" or ""
			local f_name = vim.api.nvim_buf_get_name(buf):match(".*%/(.+)")
			if f_name ~= nil then f_name = "  "..f_name.."  " else f_name = "" end

			if vim.api.nvim_get_current_buf() == buf then
				tabline = tabline.."%#StablineLeft#|"..
				"%#TablineSel#"..f_name.."%#StablineLeft#"..edited.." "
			else
				tabline = tabline.."%#TablineFill# "..f_name.. " %#TablineFill#"
			end
		end
	end
	vim.cmd("redrawtabline")

	call_tabline_colors()
	return tabline.."%#TablineFill#"
end

return {get_tabline = get_tabline}

