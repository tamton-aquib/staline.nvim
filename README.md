# staline.nvim
TLDR;<br/> staline(**sta**tus**line**): A simple statusline for neovim in pure lua.<br/>
stabline(s-**tabline**): A simple bufferline for neovim in pure lua. (sry didnt get a better name.)

PS: check out beta branch for new features like sections and lsp.
### Requirements
* Requires neovim version 0.5.0+
* `vim.opt.laststatus=2` in your init.lua for statusline.
* `vim.opt.showtabline=2` in your init.lua for tabline.

### Installation
* Vim-plug:
    ```vim
    Plug 'tamton-aquib/staline.nvim'
    ```
* Packer
    ```lua
    use { 'tamton-aquib/staline.nvim' }
    ```
**PS**: Doing this will install both staline and stabline.

# Statusline

### Screenshots
![normal](https://i.imgur.com/ZBwqI5I.png)
![insert](https://i.imgur.com/9ADMkb7.png)
![visual](https://i.imgur.com/q85p45c.png)
![command](https://i.imgur.com/F9cPtMx.png)
<!-- ![normal](https://user-images.githubusercontent.com/77913442/125925779-667db29f-66f3-45c3-a6e4-956584e477aa.png) -->
<!-- ![insert](https://user-images.githubusercontent.com/77913442/125925850-a8f84b53-ee3e-4ca1-809e-9be9e31a432e.png) -->
<!-- ![visual](https://user-images.githubusercontent.com/77913442/125925903-c39680fe-9e03-423a-b92c-10b3990de786.png) -->
<!-- ![command](https://user-images.githubusercontent.com/77913442/125928738-a42a841b-1982-4e2f-a426-260e1544f5c2.png) -->
<!-- ![command](https://user-images.githubusercontent.com/77913442/125925963-958db580-686d-4947-a68d-aea0d7bb4af8.png) -->


* Configuration
	```lua
	require('staline').setup{}
	```
* The Default configuration looks something like:
    ```lua
    require('staline').setup {
	    defaults = {
	        left_separator   = "",
	        right_separator  = "",
	        line_column      = "[%l/%L] :%c 並%p%% ", -- `:h stl` to see all flags.
	        fg               = "#000000",  -- Foreground text color.
	        bg               = "none",     -- Default background is transparent.
	        cool_symbol      = " ",       -- Change this to override defult OS icon.
	        filename_section = "center",   -- others: right, left, none or custom string.
	        full_path        = false
					branch_symbol    = " "
	    },
	    mode_colors = {
	        n = "#2bbb4f",
	        i = "#986fec",
	        c = "#e27d60",
	        v = "#4799eb",
	    },
	    mode_icons = {
	        n = " ",
	        i = " ",
	        c = " ",
	        v = " ",
	    }
    }
    ```
<details>

<summary> Some useful config Ideas: </summary>

> Create color value tables to match your current colorscheme.
```lua
local gruvbox = {
    n = "#a89985",
    i = "#84a598",
    c = "#8fbf7f",
    v = "#fc802d",    -- etc...
}

-- Assign this table as mode_colors
require('staline').setup{
	mode_colors = gruvbox
}
```
> Use non-unicode characters for showing modes.
```lua
local no_unicode_modes = {
    n = "N ",
    i = "I ",
    c = "C ",
    v = "V ",    -- etc...
}

-- Assign this table as mode_icons.
require('staline').setup{
	mode_icons = no_unicode_modes
}

-- You could change the seperators too if you want.
```
> My personal config as of editing this file:

![staline.nvim](https://i.imgur.com/TCWcnP9.png)
```lua
require('staline').setup {
    defaults = {
        cool_symbol = " ",
        left_separator = "",
        right_separator = "",
    },
    mode_colors = {
        n = "#e27d60"
    }
}
```
> Nvimtree, dashboard, and packer looks like this by default:

![Dashboard](https://i.imgur.com/QFaG8RQ.png) <br/>
![NvimTree](https://i.imgur.com/UNVxzRA.png) <br/>
![Packer](https://i.imgur.com/IPwTlFj.png) <br/>

To turn off staline in NvimTree, set this line in init.lua (from [this issue](https://github.com/glepnir/galaxyline.nvim/issues/178))
```lua
vim.cmd [[au BufEnter,BufWinEnter,WinEnter,CmdwinEnter * if bufname('%') == "NvimTree" | set laststatus=0 | else | set laststatus=2 | endif]]
```

</details>

# Bufferline

### Screenshots
![bar mode](https://i.imgur.com/stkcUAu.png)
![slant mode](https://i.imgur.com/UVS9ii5.png)
![arrow mode](https://i.imgur.com/ERDzicw.png)
![bubble mode](https://i.imgur.com/UjbeyjR.png)


* Configuration
	```lua
	require('stabline').setup{}
	```
* The Default configuration looks something like:
    ```lua
    require('stabline').setup {
	    defaults = {
	        style       = "bar", -- others: 'arrow', 'slant', 'bubble'
	        stab_left   = "┃",   -- 😬
	        stab_right  = " ",
	        fg          = Default is fg of "Normal".
	        bg          = Default is bg of "Normal".
	        stab_bg     = Default is darker version of bg.
	    },
    }
    ```
<details>

<summary>My personal config as of editing this file:</summary>

<!-- ![my stabline config](https://i.imgur.com/7PsnDGa.png) -->
![my stabline config](https://i.imgur.com/cmBdfzx.png)

```lua
require'stabline'.setup {
	style = "slant",
	bg = "#986fec",
	fg = "black",
	stab_right = ""
}
```

</details>

### Features
* Lightweight ( ~ 100 LOC each) and Fast (doesn't show up in `nvim --startuptime` logs.)
* Unicode current mode info. Needs a Nerd Font to be installed.
* Shows current git branch if [plenary](https://github.com/nvim-lua/plenary.nvim) is installed.
* Uses [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) if installed, else uses a default table.

#### Cons
* No lsp info. *(in both staline and stabline)*
* No mouse functions for stabline.
* No ordering or sorting functions for stabline.
* No git related info on staline except branch name.

---

#### Inspirations:
* [This](https://www.reddit.com/r/vim/comments/ld8h2j/i_made_a_status_line_from_scratch_no_plugins_used/) reddit post for staline.
* [akinsho/nvim-bufferline](https://github.com/akinsho/nvim-bufferline.lua) for stabline.

### TODO

- [x] Include more filetype support.
- [x] User configuration options. Needs more work.
- [x] Git info. Only branch info for now, *(or ever)*
- [x] Adding "opt-in" bufferline function.
- [x] Add config options for tabline.
