local M = {}
local staline_loaded
local conf = require("staline.config")
local util = require("staline.utils")
local colorize = util.colorize
local t = conf.defaults
local redirect = vim.fn.has('win32') == 1 and "nul" or "/dev/null"

local set_stl = function()
    for _, win in pairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_get_current_win() == win then
            vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline("active")'
        elseif vim.api.nvim_buf_get_name(0) ~= "" then
            vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline()'
        end
    end
end

-- PERF: git command for branch_name according to file location instead of cwd?
local update_branch = function()
    local cmd = io.popen('git branch --show-current 2>' .. redirect)
    local branch = ''
    if cmd ~= nil then
        branch = cmd:read("*l") or cmd:read("*a")
        cmd:close()
    end

    M.Branch_name = branch ~= "" and t.branch_symbol .. branch or ""
end

M.setup = function(opts)
    if staline_loaded then return else staline_loaded = true end
    for k,_ in pairs(opts or {}) do for k1,v1 in pairs(opts[k]) do conf[k][k1] = v1 end end

    vim.api.nvim_create_autocmd('BufEnter', {callback=update_branch})
    vim.api.nvim_create_autocmd(
        {'BufEnter', 'BufReadPost', 'ColorScheme', 'TabEnter', 'TabClosed'},
        { callback=set_stl }
    )
end

local call_highlights = function(fg, bg)
    colorize('Staline', fg, bg, t.font_active)
    colorize('StalineFill', t.fg, fg, t.font_active)
    colorize('StalineNone', nil, bg)
    colorize('DoubleSep', fg, t.inactive_color)
    colorize('MidSep', t.inactive_color, bg)
end

local get_lsp = function()
    local lsp_details = ""

    for type, sign in pairs(conf.lsp_symbols) do
        local count = #vim.diagnostic.get(0, { severity=type })
        local hl = t.true_colors and "%#DiagnosticSign"..type.."#" or " "
        local number = count > 0 and hl..sign..count.." " or ""
        lsp_details = lsp_details..number
    end

    return lsp_details
end

local get_attached_null_ls_sources = function()
    local null_ls_sources = require('null-ls').get_sources()
    local ret = {}
    for _, source in pairs(null_ls_sources) do
        if source.filetypes[vim.bo.ft] then
            if not vim.tbl_contains(ret, source.name) then
                table.insert(ret, source.name)
            end
        end
    end
    return ret
end

local lsp_client_name = function()
    local clients = {}
    for _, client in pairs(vim.lsp.get_active_clients()) do
        if t.expand_null_ls then
            if client.name == 'null-ls' then
                for _, source in pairs(get_attached_null_ls_sources()) do
                    clients[#clients + 1] = source .. t.null_ls_symbol
                end
            else
                clients[#clients + 1] = client.name
            end
        else
            clients[#clients + 1] = client.name
        end
    end
    return t.lsp_client_symbol .. table.concat(clients, ', ')
end

-- TODO: check colors inside function type
local parse_section = function(section)
    local section_type = type(section)
    if section_type == 'string' then
        if string.match(section, "^-") then
            section = section:match("^-(.+)")
            return "%#StalineFill#"..(M.sections[section] or section)
        else
            return "%#Staline#"..(M.sections[section] or section)
        end
    elseif section_type == 'function' then
        local val = section()
        if type(val) == "string" then
            return val
        elseif type(val) == "table" then
            return "%#"..val[1].."#"..val[2]
        end
    elseif section_type == 'table' then
        if #section == 1 then
            return section[1]
        elseif #section == 2 then
            if type(section[2]) == 'string' then
                return "%#"..section[1].."#"..(M.sections[section[2]] or section[2])
            elseif type(section[2]) == 'function' then
                return "%#"..section[1].."#"..section[2]()
            end
        end
    else
        vim.api.nvim_err_writeln("[staline.nvim]: Section format error!")
    end
end

M.get_statusline = function(status)
    if conf.special_table[vim.bo.ft] ~= nil then
        local special = conf.special_table[vim.bo.ft]
        return "%#Staline#%=" .. special[2] .. special[1] .. "%="
    end

    M.sections = {}

    local mode = vim.api.nvim_get_mode()['mode']
    local fgColor = status and conf.mode_colors[mode] or t.inactive_color
    local bgColor = status and t.bg or t.inactive_bgcolor
    local modeIcon = conf.mode_icons[mode] or " "

    local f_name = t.full_path and '%F' or '%t'
    -- TODO: original color of icon
    local f_icon = util.get_file_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
    local edited = vim.bo.mod and t.mod_symbol or ""
    -- TODO: need to support b, or mb?
    local size = ("%.1f"):format(vim.fn.getfsize(vim.api.nvim_buf_get_name(0))/1024)

    call_highlights(fgColor, bgColor)

    M.sections['mode']             = " "..modeIcon.." "
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
    M.sections['diagnostics']      = get_lsp()
    M.sections['lsp_name']         = lsp_client_name()
    M.sections['cwd']              = " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. " "

    local staline = ""
    for _, major in ipairs({ 'left', 'mid', 'right' }) do
        for _, section in pairs(conf.sections[major]) do
            staline = staline .. parse_section(section).."%#StalineNone#"
        end
        if major ~= 'right' then staline = staline .. "%=" end
    end

    return staline
end

return M
