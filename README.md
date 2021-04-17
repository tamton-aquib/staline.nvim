# staline.nvim
A simple statusline (can be pronounced stalin) for neovim in lua.
Haven't converted to a plugin yet, so you'll have to add it manually.

## Screenshots

![normal mode](https://i.imgur.com/5RZFhWC.png)
![insert mode](https://i.imgur.com/V0FolHn.png)
![visual mode](https://i.imgur.com/3lbiz36.png)
![command mode](https://i.imgur.com/f4lsWRD.png)

### init.vim
* move staline.lua to ~/.config/nvim/staline.lua
* Call it in init.vim :
```vim
function! Status()
    return luaeval("require('staline').get_statusline()")
endfunction

set stl=%!Status()
```
### init.lua
* move staline.lua to ~/.config/nvim/lua/staline.lua
* Call it in init.lua :
```lua
stline = require('staline')
vim.o.statusline = '%!v:lua.stline.get_statusline()'
```
