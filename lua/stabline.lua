local Stabline = {}
local util = require("staline.utils")
local stabline_loaded
local normal_bg, normal_fg
local opts = {
    style='bar', inactive_bg="#1e2127", inactive_fg="#aaaaaa",
    exclude_fts={'NvimTree', 'help', 'dashboard', 'lir', 'alpha'},
    font_active='bold', font_inactive='none'
} -- NOTE: other opts: fg, bg, stab_start, stab_end, stab_right, stab_left, stab_bg
local type_chars={ bar={left="┃", right=" "}, slant={left="", right=""}, arrow={left="", right=""}, bubble={left="", right=""} }

local refresh_colors = function()
    local normal = vim.api.nvim_get_hl_by_name('Normal', {})
    normal_bg, normal_fg = normal.background or 16777215 , normal.foreground or 0

    local stab_type = opts.style
    local bg_hex = opts.bg or ("#%06x"):format(normal_bg)
    local fg_hex = opts.fg or ("#%06x"):format(normal_fg)
    local dark_bg = opts.stab_bg or util.extract_hl('NormalFloat', true) -- TODO: clean later?
    local inactive_bg, inactive_fg = opts.inactive_bg, opts.inactive_fg
    local active, inactive = {}, {}

    if stab_type == "bar" then
        active = { left = {f = fg_hex, b = bg_hex}, right = {f = fg_hex, b = bg_hex} }
        inactive = { left = {f = inactive_bg, b = inactive_bg}, right = {f = fg_hex, b = inactive_bg} }
    elseif stab_type == "slant" then
        active = { left = {f = bg_hex, b = dark_bg}, right = {f = bg_hex, b = dark_bg} }
        inactive = { left = {f = inactive_bg, b = dark_bg}, right = {f = inactive_bg, b = dark_bg} }
    elseif stab_type == "arrow" then
        active = { left = {f = dark_bg, b = bg_hex}, right = {f = bg_hex, b = dark_bg} }
        inactive = { left = {f = dark_bg, b = inactive_bg}, right = {f = inactive_bg, b = dark_bg} }
    elseif stab_type == "bubble" then
        active = { left = {f = bg_hex, b = dark_bg}, right = {f = bg_hex, b = dark_bg} }
        inactive = { left = {f = inactive_bg, b = dark_bg}, right = {f = inactive_bg, b = dark_bg} }
    end

    util.colorize('StablineSel', fg_hex, bg_hex, opts.font_active)
    util.colorize('Stabline', nil, dark_bg, nil)
    util.colorize('StablineLeft',active.left.f, active.left.b, nil)
    util.colorize('StablineRight',active.right.f, active.right.b)
    util.colorize('StablineInactive', inactive_fg, inactive_bg, opts.font_inactive)
    util.colorize('StablineInactiveRight', inactive.right.f, inactive.right.b)
    util.colorize('StablineInactiveLeft', inactive.left.f, inactive.left.b)
end

Stabline.setup = function(setup_opts)
    if stabline_loaded then return else stabline_loaded = true end
    opts = vim.tbl_deep_extend('force', opts, setup_opts or {})

    vim.api.nvim_create_autocmd({'BufEnter', 'ColorScheme'}, {
        callback = refresh_colors, pattern = "*"
    })
    vim.o.tabline = '%!v:lua.require\'stabline\'.get_tabline()'
end

local do_icon_hl = function(icon_hl)
    local new_fg = util.extract_hl(icon_hl)
    local icon_bg = opts.bg or string.format("#%06x", normal_bg)
    vim.api.nvim_set_hl(0, 'StablineTempHighlight', {bg=icon_bg, fg=new_fg})
    return '%#StablineTempHighlight#'
end

Stabline.get_tabline = function()
    local stab_type = opts.style
    local stab_left = opts.stab_left or type_chars[stab_type].left
    local stab_right= opts.stab_right or type_chars[stab_type].right
    local tabline = opts.stab_start and ("%#Stabline#"..opts.stab_start) or "%#Stabline#"

    for _, buf in pairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            local edited = vim.bo.modified and "" or " "

            local f_name = vim.api.nvim_buf_get_name(buf):match("^.+/(.+)$") or ""
            local ext = string.match(f_name, "%w+%.(.+)")
            local f_icon, icon_hl = util.get_file_icon(f_name, ext)

            local conditions = vim.tbl_contains(opts.exclude_fts, vim.bo[buf].ft) or f_name == ""
            if conditions then goto do_nothing else f_name = " ".. f_name .." " end

            local s = vim.api.nvim_get_current_buf() == buf

            -- TODO: change to `format` so as to remove padding??
            tabline = tabline..
            "%#Stabline"..(s and "" or "Inactive").."Left#"..stab_left..
            "%#Stabline"..(s and "Sel" or "Inactive").."#   "..
            (" "):rep(opts.padding or 1)..
            (s and do_icon_hl(icon_hl) or "")..f_icon..
            "%#Stabline"..(s and "Sel" or "Inactive").."#"..f_name.." "..
            (" "):rep(opts.padding or 1).. (s and edited or " ")..
            "%#Stabline"..(s and "" or "Inactive").."Right#"..stab_right
        end
        ::do_nothing::
    end

    return tabline.."%#Stabline#%="..(opts.stab_end or "")
end

return Stabline
