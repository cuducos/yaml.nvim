# yaml.nvim

Simple tools to help developers working YAML in [Neovim](https://neovim.io):

| Command | Description |
|:--|:--|
| `:YAMLView` | Shows the full path and value of the current key/value pair |
| `:YAMLYank` | Yanks the full path and value of the current key/value pair |
| `:YAMLYankKey` | Yanks the full path of the key for the current key/value pair |
| `:YAMLYankValue` | Yanks the value of the current key/value pair |
| `:YAMLQuickfix` | Generates a quickfix with key/balue pairs |
| `:YAMLTelescope` | Full path key/value fuzzy finder via [Telescope](https://github.com/nvim-telescope/telescope.nvim) **if installed** |

By now, it only uses to unnamed register to yank ([**TODO** allow users to choose which register to yank to](https://github.com/cuducos/yaml.nvim/issues/6)).

![Example GIF](doc/demo.gif)

It requires [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) with [YAML support](https://github.com/ikatyang/tree-sitter-yaml). Telescope is **optional**.

Install with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "cuducos/yaml.nvim",
  ft = {"yaml"}, -- optional
  requires = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim" -- optional
  },
  config = function ()
    require("yaml_nvim").init()
  end,
}
```
