# yaml.nvim

Simple tools to help developers working YAML in [Neovim](https://neovim.io):

| Command | Description |
|:--|:--|
| `:YAMLView` | Shows the full path and value of the current key/value pair |
| `:YAMLYank [register]` | Yanks the full path and value of the current key/value pair. The default register is the unnamed one (`"`) |
| `:YAMLYankKey [register]` | Yanks the full path of the key for the current key/value pair. The default register is the unnamed one (`"`) |
| `:YAMLYankValue [regster]` | Yanks the value of the current key/value pair. The default register is the unnamed one (`"`) |
| `:YAMLQuickfix` | Generates a quickfix with key/value pairs |
| `:YAMLTelescope` | Full path key/value fuzzy finder via [Telescope](https://github.com/nvim-telescope/telescope.nvim) **if installed** |

![Example GIF](doc/demo.gif)

It requires **Neovim 0.7** or newer, [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) with [YAML support](https://github.com/ikatyang/tree-sitter-yaml). Telescope is **optional**.

For **Neovim 0.5 or 0.6**, pin to [`155c23d`](https://github.com/cuducos/yaml.nvim/commit/155c23de8f99fdb424f8aa713bcb993cc2538c6c).

Install with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "cuducos/yaml.nvim",
  ft = {"yaml"}, -- optional
  requires = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim" -- optional
  },
}
```

Install with [vim-plug](https://github.com/junegunn/vim-plug):
```viml
" optional
Plug 'nvim-telescope/telescope.nvim'

" required
Plug 'nvim-treesitter/nvim-treesitter'

Plug 'cuducos/yaml.nvim'
```
