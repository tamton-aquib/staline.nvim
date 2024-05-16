local M = {}
local staline_loaded
local conf = require("staline.config")
local util = require("staline.utils")
local colorize = util.colorize
local t = conf.defaults

local set_stl = function()
    for _, win in pairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_get_current_win() == win then
            vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline("active")'
        elseif vim.api.nvim_buf_get_name(0) ~= "" then
            vim.wo[win].statusline = '%!v:lua.require\'staline\'.get_statusline()'
        end
    end
end

local update_branch = function()
    vim.b.staline_branch = ""
    if vim.b.gitsigns_head then
        vim.b.staline_branch = vim.b.gitsigns_head and (t.branch_symbol .. vim.b.gitsigns_head) or ""
        return
    end
    vim.fn.jobstart({"git", "branch", "--show-current"}, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            local branch = data[1]
            vim.b.staline_branch = branch ~= "" and t.branch_symbol .. branch or ""
        end
    })
end

M.setup = function(opts)
    if staline_loaded then return else staline_loaded = true end
    for k,_ in pairs(opts or {}) do for k1,v1 in pairs(opts[k]) do conf[k][k1] = v1 end end

    vim.api.nvim_create_autocmd({'BufReadPost', 'DirChanged'}, {callback=update_branch})
    vim.api.nvim_create_autocmd(
        { 'BufEnter', 'BufReadPost', 'ColorSchemePre', 'TabEnter', 'TabClosed', 'Filetype' },
        { callback = set_stl }
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
    local clients_name = ""
    local the_symbol = t.lsp_client_symbol
    local name_max_length = t.lsp_client_character_length

    for _, client in pairs(vim.lsp.get_active_clients()) do -- Deprecated?
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
    clients_name = table.concat(clients, ', ')

    -- NOTE: Only show XX characters if the "clients_name" is too long
    if name_max_length <= 0 then
        return the_symbol .. clients_name
    else
        local clients_length = string.len(clients_name)
        local clients_truncated_name = ""

        if clients_length >= name_max_length then
            clients_truncated_name = string.sub(clients_name, 1, name_max_length)
            clients_truncated_name = #clients .. ":(" .. clients_truncated_name .. "...)"
            return the_symbol .. clients_truncated_name
        elseif clients_length == 0 then
            return the_symbol .. #clients .. ":(" .. "LSP" .. ")"
        else
            return the_symbol .. #clients .. ":(" .. clients_name .. ")"
        end
    end
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
    local fg_color = status and conf.mode_colors[mode] or t.inactive_color
    local bg_color = status and t.bg or t.inactive_bgcolor
    local modeIcon = conf.mode_icons[mode] or "󰋜 "

    local f_name = t.full_path and '%F' or '%t'
    -- TODO: original color of icon
    local f_icon, f_icon_hl = util.get_file_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
    local edited = vim.bo.mod and t.mod_symbol or ""
    -- TODO: need to support b, or mb?
    local size = ("%.1f"):format(vim.fn.getfsize(vim.api.nvim_buf_get_name(0))/1024)

    call_highlights(fg_color, bg_color)

    M.sections['mode']             = " "..modeIcon.." "
    M.sections['branch']           = " "..("%{get(b:, 'staline_branch', '')}").." "
    M.sections['git_branch']       = " "..("%{get(b:, 'staline_branch', '')}").." "
    M.sections['git_diff']         = " "..("%{get(b:, 'gitsigns_status', '')}").." "
    M.sections['file_name']        = " "..f_icon.." "..f_name..edited.." "
    M.sections['f_name']           = f_name
    M.sections['f_icon']           = (t.true_colors and ("%#"..f_icon_hl.."#") or "") .. f_icon
    M.sections['f_modified']       = edited
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
    local section_t = status and 'sections' or 'inactive_sections'
    for _, major in ipairs({ 'left', 'mid', 'right' }) do
        -- fix background glitch
        if conf[section_t]['left'][1] == nil then
            conf[section_t]['left'][1] = ' '
        end

        for _, section in pairs(conf[section_t][major]) do
            staline = staline .. parse_section(section).."%#StalineNone#"
        end
        if major ~= 'right' then staline = staline .. "%=" end
    end

    return staline
end

return M
