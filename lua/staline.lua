local M = {}
local Tables = require('tables')
local t =  Tables.defaults

function M.set_statusline()
	for _, win in pairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_get_current_win() == win then
			vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline("active")'
		elseif vim.api.nvim_buf_get_name(0) ~= "" then
			vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline()'
		end
	end
end

function M.setup(opts)
	for k,_ in pairs(opts or {}) do for k1,v1 in pairs(opts[k]) do Tables[k][k1] = v1 end end

	vim.cmd [[au BufEnter,WinEnter,BufWinEnter,BufReadPost,ColorScheme * lua require'staline'.set_statusline()]]
	vim.cmd [[au BufEnter,WinEnter,BufWinEnter,BufReadPost * lua require'staline'.update_branch()]]
end

-- PERF: git command for branch_name according to file location instead of cwd
function M.update_branch()
	local cmd = io.popen('git branch --show-current 2> /dev/null')
	local branch = cmd:read("*l") or cmd:read("*a")
	cmd:close()

	if branch ~= "" then
		M.Branch_name = t.branch_symbol .. branch
	else
		M.Branch_name = ""
	end
end

local function get_file_icon(f_name, ext)
	local status, icons = pcall(require, 'nvim-web-devicons')
	if not status then return Tables.file_icons[ext] end
	return icons.get_icon(f_name, ext, {default = true})
end

local function call_highlights(fgColor, bgColor)
	vim.cmd('hi Staline guifg='..fgColor..' guibg='..bgColor..' gui='..t.font_active)
	vim.cmd('hi StalineFill guibg='..fgColor..' guifg='..t.fg..' gui='..t.font_active)
	vim.cmd('hi StalineNone guifg=none guibg='..bgColor)
	vim.cmd('hi DoubleSep guifg='..fgColor..' guibg=#303030')
	vim.cmd('hi MidSep guifg='.."#303030"..' guibg='..bgColor)
end

local function get_lsp()
	local lsp_details = ""

	for type, sign in pairs(Tables.lsp_symbols or {}) do
		local count = vim.lsp.diagnostic.get_count(0, type)
		local hl = t.true_colors and "%#Diagnostic"..type.."#" or " "
		local number = count > 0 and hl..sign..count.." " or ""
		lsp_details = lsp_details..number
	end

	return lsp_details
end

local function lsp_client_name()
	local clients = {}
	for _, client in pairs(vim.lsp.buf_get_clients(0)) do
		clients[#clients+1] = t.lsp_client_symbol .. client.name
	end
	return table.concat(clients, ' ')
end

-- TODO: should this be changed to {'section', fg, bg} ?
local function parse_section(section)
	if type(section) == 'string' then
		if string.match(section, "^-") then
			section = section:match("^-(.+)")
			return "%#StalineFill#"..(M.sections[section] or section)
		else
			return "%#Staline#"..(M.sections[section] or section)
		end
	elseif type(section) == 'function' then
		return "%#Staline#"..section()
	else
		return "%#"..section[1].."#"..(M.sections[section[2]] or section[2])
	end
end

function M.get_statusline(status)
	if Tables.special_table[vim.bo.ft] ~= nil then return "%#Staline#%=" .. Tables.special_table[vim.bo.ft][2] .. Tables.special_table[vim.bo.ft][1] .. "%=" end

	M.sections = {}

	local mode = vim.api.nvim_get_mode()['mode']
	local fgColor = status and Tables.mode_colors[mode] or t.inactive_color
	local bgColor = status and t.bg or t.inactive_bgcolor
	local modeIcon = Tables.mode_icons[mode] or " "

	local f_name = t.full_path and '%F' or '%t'
	-- TODO: original color of icon
	local f_icon = get_file_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
	local edited = vim.bo.mod and t.mod_symbol or ""
	-- TODO: need to support b, or mb
	local size = string.format("%.1f", vim.fn.getfsize(vim.api.nvim_buf_get_name(0))/1024)

	call_highlights(fgColor, bgColor)

	M.sections['mode']             = (" "..modeIcon.." ")
	M.sections['branch']           = " "..(M.Branch_name or "").." "
	M.sections['file_name']        = " "..f_icon.." "..f_name..edited.." "
	M.sections['file_size']        = " " ..size.. "k "
	M.sections['cool_symbol']      = " "..t.cool_symbol.." "
	M.sections['line_column']      = " "..t.line_column.." "
	M.sections['left_sep']         = t.left_separator
	M.sections['right_sep']        = t.right_separator
	M.sections['left_sep_double']  = "%#DoubleSep#"..t.left_separator.."%#MidSep#"..t.left_separator
	M.sections['right_sep_double'] = "%#MidSep#"..t.right_separator.."%#DoubleSep#"..t.right_separator
	M.sections['lsp']              = get_lsp()
	M.sections['lsp_name']         = lsp_client_name()
	M.sections['cwd']              = " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. " "

	local staline = ""
	for _, major in ipairs({ 'left', 'mid', 'right' }) do
		for _, section in pairs(Tables.sections[major]) do
			staline = staline .. parse_section(section).."%#StalineNone#"
		end
		if major ~= 'right' then staline = staline .. "%=" end
	end

	return staline
end

return M
