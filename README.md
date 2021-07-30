# staline.nvim
TLDR;<br/> staline(**sta**tus**line**): A simple statusline for neovim written in lua.<br/>
stabline(s-**tabline**): A simple bufferline for neovim written in lua. (sry didnt get a better name.)

### Requirements
* Requires neovim version 0.5.0+
* `vim.opt.laststatus=2` in your init.lua for statusline.
* `vim.opt.showtabline=2` in your init.lua for bufferline.

### Installation
* Vim-plug:
    ```vim
    Plug 'tamton-aquib/staline.nvim'
    ```
* Packer
    ```lua
    use 'tamton-aquib/staline.nvim'
    ```
**PS**: Doing this will install both staline and stabline.

# Statusline

#### Screenshots
![normal](https://i.imgur.com/ZBwqI5I.png)
![insert](https://i.imgur.com/9ADMkb7.png)
![visual](https://i.imgur.com/q85p45c.png)
![command](https://i.imgur.com/F9cPtMx.png)


#### Configuration
```lua
require('staline').setup{}
```
<details>
<summary> The Default configuration looks something like: </summary>

```lua
require('staline').setup {
	sections = {
		left  = { '-mode', 'left_sep_double', ' ', 'branch', 'lsp' },
		mid   = { 'filename' },
		right = { 'cool_symbol','right_sep_double', '-line_column' }
	},
	defaults = {
		left_separator   = "",
		right_separator  = "",
		line_column      = "[%l/%L] :%c 並%p%% ", -- `:h stl` to see all flags.
		fg               = "#000000",  -- Foreground text color.
		bg               = "none",     -- Default background is transparent.
		cool_symbol      = " ",       -- Change this to override defult OS icon.
		filename_section = "center",   -- others: right, left, none or custom string.
		full_path        = false
	},
	mode_colors = {
		n = "#2bbb4f",
		i = "#986fec",
		c = "#e27d60",
		v = "#4799eb",   -- etc..
	},
	mode_icons = {
		n = " ",
		i = " ",
		c = " ",
		v = " ",   -- etc..
	}
}
```
</details>

<details>
<summary> All sections: </summary>

| section | use |
|---------|-----|
| mode         | shows the mode       |
| branch       | shows git branch |
| filename     | shows filename |
| cool_symbol  | an icon according to the OS type (cutomizable) |
| lsp          | lsp diagnostics (number of errors, warnings, etc) |
| line_column  | shows line, column, percentage, etc |
| left_sep     | single left separator |
| right_sep    | single right separator |
| left_sep_double    | Double left separator with a shade of gray |
| right_sep_double    | Double right separator with a shade of gray |

**PS: adding '-' to front of a section inverts the fg and bg colors.** (as seen in the default example)

</details>

<details>
<summary> Highlights: </summary>
<br />
<li> The `-` in front of sections inverts the color of that section. </li>

Example:
`sections = { mid = { 'filename' } }`
will look like: <br />
![highilight_example](https://i.imgur.com/rp0Vei4.png)

now, adding `-` at the beginning:
`sections = { mid = { '-filename' } }`
will look like:
![highlight_example2](https://i.imgur.com/mhXa9Ku.png)

<li> If you want a specific highlight for a single section, specify it as a table like { highlight, section } </li>

`sections = { mid = { { 'RandomHighlight', '-filename' } } }` <br />
and then later `vim.cmd('highlight RandomHighlight guifg=#000000 guibg=#ffffff')` <br />
or provide an already defined highlight (`LspDiagnosticsError`, `Visual`)

</details>

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

<!-- ![staline.nvim](https://i.imgur.com/TCWcnP9.png) -->
![staline.nvim](https://i.imgur.com/7mrzpBK.png)
<!-- https://i.imgur.com/7mrzpBK.png -->

```lua
require'staline'.setup{
	sections = {
		left = {'-mode', 'left_sep_double', 'filename', '  ', 'branch'},
		mid  = {'lsp'},
		right= { 'cool_symbol', '  ', vim.bo.fileencoding, 'right_sep_double', '-line_column'}
	},
	defaults = {
		cool_symbol = "  ",
		left_separator = "",
		right_separator = "",
		bg = "#303030",
		full_path = true
		branch_symbol = " "
	},
	mode_colors = {
		n = "#986fec",
		i = "#e86671",
		ic= "#e86671",
		c = "#e27d60"
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
* Lightweight ( below 150 LOC each) and Fast.
* Unicode current mode info. Needs a Nerd Font to be installed.
* Shows current git branch if [plenary](https://github.com/nvim-lua/plenary.nvim) is installed.
* Uses [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) if installed, else uses a default table.

#### Cons
* No mouse functions for stabline.
* No ordering or sorting functions for stabline.
* No lsp info in stabline.
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
