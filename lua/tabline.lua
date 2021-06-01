Tabline = {}

function Tabline.get_tabline()
	local tabline = ""

	for i in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(i) == true then 
			local f_name = vim.api.nvim_buf_get_name(i):match(".*%/(.+)") or "[No Name]"
			if f_name:match("Vim.Buffer") then f_name = "" end

			if vim.api.nvim_get_current_buf() == i then
				tabline = tabline.."%#TablineSel# "..f_name.." "
			else
				tabline = tabline.." %#Staline# "..f_name.." "
			end
		end
	end

	return tabline.."%#StalineFill#"
end

return Tabline

