# staline.nvim
A simple statusline for neovim written in lua.

### Screenshots
![normal mode](https://i.imgur.com/1gXX22o.png)
![insert mode](https://i.imgur.com/0bP6y0S.png)
![visual mode](https://i.imgur.com/v1sejC8.png)
![command mode](https://i.imgur.com/TD9CGJ6.png)


### Installation
* Vim-plug:
    ```vim
    Plug 'tamton-aquib/staline.nvim'
    ```
* Packer
    ```lua
    use { 'tamton-aquib/staline.nvim' }
    ```

### Setting up

* Configuration
	```lua
	require('staline').setup{}
	```
* The Default configuration looks something like:
    ```lua
    require('staline').setup {
		defaults = {
            leftSeparator   = "",
            rightSeparator  = "",
            cool_symbol     = " "  -- Change this to override defult OS icon.
		},
		getModeColor = {
			n = "#2bbb4f",
			i = "#986fec",
			c = "#e27d60",
			v = "#4799eb",
		},
		modes = {
			n = " ",
			i = " ",
			c = " ",
			v = " ",
		}
    }
    ```
* Useful config Ideas:
	> create color value tables yourself to match your current colorscheme.
	```lua
	local gruvbox = {
		n = "#a89985",
		i = "#84a598",
		c = "#8fbf7f",
		v = "#fc802d",
	}
	
	-- Assign getModeColor as this table.
	require('staline').setup{
		getModeColor = gruvbox
	}
	```

### Features
* Lightweight (~100 LOC)
* Fast
* Unicode current mode info.
* Shows current git branch if `plenary` is installed. (If you have telescope, you will probably have this.)

### TODO

- [x] Include more filetype support.
- [x] Git info. Only branch info for now
- [x] User configuration options. Needs more work.
- [ ] Break into modules.
