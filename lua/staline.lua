local M = {}
local staline_loaded
local Tables = require('staline.config')
local colorize = require("staline.utils").colorize
local t = Tables.defaults
local redirect = vim.fn.has('win32') == 1 and "nul" or "/dev/null"

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
	if staline_loaded then return else staline_loaded = true end
	for k,_ in pairs(opts or {}) do for k1,v1 in pairs(opts[k]) do Tables[k][k1] = v1 end end

	vim.api.nvim_create_autocmd('BufEnter', {callback=M.update_branch, pattern="*"})
    vim.api.nvim_create_autocmd({'BufEnter', 'BufReadPost', 'ColorScheme'}, {
        pattern="*", callback=M.set_statusline
    })
end

-- PERF: git command for branch_name according to file location instead of cwd?
function M.update_branch()
	local cmd = io.popen('git branch --show-current 2>' .. redirect)
	local branch = cmd:read("*l") or cmd:read("*a")
	cmd:close()

	M.Branch_name = branch ~= "" and t.branch_symbol .. branch or ""
end

local function get_file_icon(f_name, ext)
	local status, icons = pcall(require, 'nvim-web-devicons')
	if not status then return Tables.file_icons[ext] or " " end
	return icons.get_icon(f_name, ext, {default = true})
end

local function call_highlights(fg, bg)
	colorize('Staline', fg, bg, t.font_active)
	colorize('StalineFill', t.fg, fg, t.font_active)
	colorize('StalineNone', nil, bg)
	colorize('DoubleSep', fg, t.inactive_color)
	colorize('MidSep', t.inactive_color, bg)
end

local function get_lsp()
	local lsp_details = ""

	for type, sign in pairs(Tables.lsp_symbols) do
		local count = #vim.diagnostic.get(0, { severity=type })
		local hl = t.true_colors and "%#Diagnostic"..type.."#" or " "
		local number = count > 0 and hl..sign..count.." " or ""
		lsp_details = lsp_details..number
	end

	return lsp_details
end

local function lsp_client_name()
	local clients = {}
	for _, client in pairs(vim.lsp.buf_get_clients(0)) do
		clients[#clients+1] = client.name
	end
	return t.lsp_client_symbol .. table.concat(clients, ',')
end

-- TODO: check colors inside function type
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
	if Tables.special_table[vim.bo.ft] ~= nil then
		local special = Tables.special_table[vim.bo.ft]
		return "%#Staline#%=" .. special[2] .. special[1] .. "%="
	end

	M.sections = {}

	local mode = vim.api.nvim_get_mode()['mode']
	local fgColor = status and Tables.mode_colors[mode] or t.inactive_color
	local bgColor = status and t.bg or t.inactive_bgcolor
	local modeIcon = Tables.mode_icons[mode] or " "

	local f_name = t.full_path and '%F' or '%t'
	-- TODO: original color of icon
	local f_icon = get_file_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
	local edited = vim.bo.mod and t.mod_symbol or ""
	-- TODO: need to support b, or mb?
	local size = ("%.1f"):format(vim.fn.getfsize(vim.api.nvim_buf_get_name(0))/1024)

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

	-- TODO: use tables instead of string maybe
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
