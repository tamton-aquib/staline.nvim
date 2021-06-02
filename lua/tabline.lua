Tabline = {}

function Tabline.get_tabline()
	local tabline = ""
	local normal_bg = vim.api.nvim_get_hl_by_name("Normal", {})['background']
	local normal_fg = vim.api.nvim_get_hl_by_name("Normal", {})['foreground']
 	local normal_bg_hex = string.format("%x", normal_bg)
	local normal_fg_hex = string.format("%x", normal_fg)

 	-- vim.cmd('hi TablineSel guibg='..normal_bg_hex..' guifg='..normal_fg_hex..' gui=bold')
	-- vim.cmd('hi Tabline guibg=black')

	for i in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(i) == false then 
			tabline = tabline .. "%#TablineSel# NoName "
		else
			local f_name = vim.api.nvim_buf_get_name(i):match(".*%/(.+)") or "[No Name]"
			if f_name:match("Vim.Buffer") then f_name = "" end

			if vim.api.nvim_get_current_buf() == i then
				tabline = tabline.."%#TablineSel# "..f_name.." "
			else
				tabline = tabline.."%#Tabline# "..f_name.." " .. "%#TablineFill#"
			end
		end
	end

	return tabline.."%#TablineFill#"
end

return Tabline

