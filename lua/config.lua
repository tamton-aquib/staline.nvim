Config = {}

function system_icon()
	if vim.fn.has("win32") == 1 then
		return "者"
	elseif vim.fn.has("unix") == 1 then
		return " "
	elseif vim.fn.has("mac") == 1 then
		return " "
	end
end

Config.defaults = {
    leftSeparator = "",
    rightSeparator = "",
	cool_symbol = system_icon()
}

function Config.setup(opts)
    if not opts then return end
    for k, v in pairs(opts) do Config.defaults[k] = v end
    vim.o.statusline = '%!v:lua.require\'staline\'.get_statusline()'
end

return Config
