# yaml.nvim (work in progress)

Simple tools to help developers working YAML in [Neovim](https://neovim.io):

| Command | Description |
|:--|:--|
| `:YAMLView` | Shows the full path and value of the current key/value pair |
| `:YAMLYank` | Yanks the full path and value of the current key/value pair |
| `:YAMLYankKey` | Yanks the full path of the key for the current key/value pair |
| `:YAMLYankValue` | Yanks the value of the current key/value pair |
| `:Telescope yaml` | [**TODO** Full path key/value fuzzy finder](https://github.com/cuducos/yaml.nvim/issues/5) via [Telescope](https://github.com/nvim-telescope/telescope.nvim) **if installed** |

By now, it only uses to unnamed register to yank ([**TODO** allow users to choose which register to yank to](https://github.com/cuducos/yaml.nvim/issues/6)).

## Example

Given this YAML is loaded in the buffer:

```yaml
worldcup:
  year: 2014
  host: Brazil

  semifinals:
    - brazil: 1
      germany: 7
    - netherlands: 0
      argentina: 0
```

The result would be `worldcup.host = Brazil` for line 3, or
`worldcup.semifinals[0].germany = 7` for line 7.

In Telescope, the list would look like this:

```
worldcup.year = 2014
worldcup.host = Brazil
worldcup.semifinals[0].brazil = 1
worldcup.semifinals[0].germany = 7
worldcup.semifinals[1].netherlands = 0
worldcup.semifinals[1].argentina = 0
```

Each selection would position the cursor on lines 2, 3, 6, 7, 8 or 9
respectively.

## Install

It requires [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) with [YAML support](https://github.com/ikatyang/tree-sitter-yaml). Telescope is **optional**.

With [packer.nvim](https://github.com/wbthomason/packer.nvim):

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
