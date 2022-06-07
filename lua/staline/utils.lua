local U = {}

U.get_file_icon = function(f_name, ext)
    local status, icons = pcall(require, 'nvim-web-devicons')
    if not status then return require('staline.config').file_icons[ext] or " " end
    return icons.get_icon(f_name, ext, {default = true})
end


U.extract_hl = function(hl, fore)
    return ("#%06x"):format(
        vim.api.nvim_get_hl_by_name(hl, true)[fore and 'background' or 'foreground'] or 255
    )
end

U.colorize = function(n, fg, bg, style)
    local stuff = {}
    stuff['fg'] = fg and fg or nil
    stuff['bg'] = bg and bg or nil
    if style then
        for _,v in ipairs(vim.split(style, ',')) do
            if v:lower() ~= 'none' then stuff[v]=true end
        end
    end

    vim.api.nvim_set_hl(0, n, stuff)
end

U.system_icon = function()
    if vim.fn.has("win32")    == 1 then return "者"
    elseif vim.fn.has("mac")  == 1 then return " "
    elseif vim.fn.has("unix") == 1 then return " "
    end
end

return U
