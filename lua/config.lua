Config = {}

Config.defaults = {
    leftSeparator = "",
    rightSeparator = "",
	cool_symbol = " "
}

function Config.setup(opts)
    if not opts then return end
    for k, v in pairs(opts) do Config.defaults[k] = v end
    vim.o.statusline = '%!v:lua.require\'noice\'.get_statusline()'
end

return Config
