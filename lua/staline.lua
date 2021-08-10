M = {}
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
	for k,_ in pairs(opts or {}) do
		for k1,v1 in pairs(opts[k]) do Tables[k][k1] = v1 end
	end

	vim.cmd [[au BufEnter,BufWinEnter,WinEnter,BufReadPost * lua require'staline'.set_statusline()]]
	vim.cmd [[au BufEnter,WinEnter,BufWinEnter,BufReadPost * lua require'staline'.update_branch()]]
end

function M.update_branch()
	if not pcall(require, 'plenary') then return "" end

	local branch_name = require('plenary.job'):new({
		command = 'git', args = { 'branch', '--show-current' },
	}):sync()[1]

	M.Branch_name =  branch_name and t.branch_symbol..branch_name or ""
end

local function get_file_icon(f_name, ext)
	if not pcall(require, 'nvim-web-devicons') then
		return Tables.file_icons[ext] end
	return require'nvim-web-devicons'.get_icon(f_name, ext, {default = true})
end

local function call_highlights(modeColor)
	vim.cmd('hi Staline guibg='..modeColor..' guifg='..t.fg..' gui='..t.font_active )
	vim.cmd('hi StalineNone guifg=none guibg='..t.bg)
	vim.cmd('hi DoubleSep guifg='..modeColor..' guibg=#303030')
	vim.cmd('hi MidSep guifg='.."#303030"..' guibg='..t.bg)
	vim.cmd('hi StalineInvert guifg='..modeColor..' guibg='..t.bg..' gui='..t.font_active)
end

local function get_lsp()
	local lsp_details = ""
	for type, sign in pairs(Tables.lsp_symbols or {}) do
		local count = vim.lsp.diagnostic.get_count(0, type)
		local hl = t.true_colors and "%#LspDiagnosticsDefault"..type.."#" or " "
		local number = count > 0 and hl..sign..count.." " or ""
		lsp_details = lsp_details..number
	end

	return lsp_details
end

local function client_name()
	for _, name in pairs(vim.lsp.get_active_clients()) do
		return name == vim.bo.ft and "" or name.name
	end
end

local function check_section(section)
	if type(section) == 'string' then
		if string.match(section, "^-") then
			section = section:match("^-(.+)")
			return "%#Staline#"..(M.sections[section] or section)
		else
			return "%#StalineInvert#"..(M.sections[section] or section)
		end
	else
		return "%#"..section[1].."#"..(M.sections[section[2]] or section[2])
	end
end

function M.get_statusline(status)
	M.sections = {}

	local mode = vim.api.nvim_get_mode()['mode']
	local modeColor = status and Tables.mode_colors[mode] or t.inactive_color

	local f_name = t.full_path and '%F' or '%t'
	local f_icon = get_file_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
	local edited = vim.bo.mod and "  " or ""

	call_highlights(modeColor)

	local roger = Tables.special_table[vim.bo.ft]
	if status and roger then
		return "%#StalineInvert#%="..roger[2]..roger[1].."%="
	end

	M.sections['mode']             = (" "..Tables.mode_icons[mode].." ") or "  "
	M.sections['branch']           = " "..(M.Branch_name or "").." "
	M.sections['filename']         = " "..f_icon.." "..f_name..edited.." "
	M.sections['cool_symbol']      = " "..t.cool_symbol.." "
	M.sections['line_column']      = " "..t.line_column.." "
	M.sections['left_sep']         = t.left_separator
	M.sections['right_sep']        = t.right_separator
	M.sections['left_sep_double']  = "%#DoubleSep#"..t.left_separator.."%#MidSep#"..t.left_separator
	M.sections['right_sep_double'] = "%#MidSep#"..t.right_separator.."%#DoubleSep#"..t.right_separator
	M.sections['lsp']              = get_lsp()
	M.sections['lsp_name']         = client_name()

	local staline = ""
	for _, major in pairs({ 'left', 'mid', 'right'}) do
		for _, section in pairs(Tables.sections[major]) do
			staline = staline .. check_section(section).."%#StalineNone#"
		end
		if major ~= 'right' then staline = staline .. "%=" end
	end

	return staline
end

return M
