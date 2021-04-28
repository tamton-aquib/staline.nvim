# staline.nvim
A simple statusline for neovim written in lua.

### Screenshots
![normal mode](https://i.imgur.com/5RZFhWC.png)
![insert mode](https://i.imgur.com/V0FolHn.png)
![visual mode](https://i.imgur.com/3lbiz36.png)
![command mode](https://i.imgur.com/f4lsWRD.png)


### Installation
* Vim-plug:
    ```vim
    Plug 'tamton-aquib/staline.nvim'
    ```
* Packer
    ```lua
    use { 'tamton-aquib/staline.nvim' }
    ```

* Paq
    ```lua
    paq 'tamton-aquib/staline.nvim'
    ```

* Dein
    ```vim
    call dein#add('tamton-aquib/staline.nvim')
    ```
### Setting up

* Default configuration
    ```lua
    require('staline').setup{
            leftSeparator = "",
            rightSeparator = ""
    }
    ```

### Features
* Lightweight (2.3 kb)
* Fast
* Unicode current mode info.

### TODO

- [ ] User configuration options.
- [ ] Git info.
- [ ] Break into modules.
- [ ] Include more filetype support.
