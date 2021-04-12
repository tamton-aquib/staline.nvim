# stalin.nvim
A simple statusline (hence the name stalin) for neovim in lua.
Haven't converted to a plugin yet, so you'll have to add it manually.

## Screenshots

![normal mode](https://i.imgur.com/HyXHJtc.png)
![insert mode](https://i.imgur.com/DHyBp1A.png)
![visual mode](https://i.imgur.com/RFO2PSm.png)

### init.vim
* move stalin.lua to ~/.config/nvim/stalin.lua
* Call it in init.vim :
```vim
function! Status()
    return luaeval("require('stalin').get_statusline()")
endfunction

set stl=%!Status()
```
### init.lua
* move stalin.lua to ~/.config/nvim/lua/stalin.lua
* Call it in init.lua :
```lua
stline = require('stalin')
vim.o.statusline = '%!v:lua.stline.get_statusline()'
```
