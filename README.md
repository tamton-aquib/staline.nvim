# staline.nvim Beta Branch
A simple statusline (can be pronounced stalin) for neovim in lua.
Haven't converted to a plugin yet, so you'll have to add it manually.

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

### Features
* Lightweigth
* Fast
* Unicode mode info.
* 100 LOC.

### TODO

- [ ] User configuration options.
- [ ] Git info.
- [ ] Break into modules.
- [ ] Include more filetype support.
