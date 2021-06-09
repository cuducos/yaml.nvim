# yaml.nvim (work in progress)

Simple tools to help developers working YAML in [Neovim](https://neovim.io). It
offers basic functionalities. According to the line where the cursor is:

1. Shows the full path and value of the current key/value pair.
    * **TODO** Support array indexes
1. **TODO**Yanks the full path and value of the current key/value pair.
1. **TODO** Yanks the full path of the key for the current key/value pair.
1. **TODO** Integrates with [Telescope](https://github.com/nvim-telescope/telescope.nvim)

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

It requires:
  * [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter)
  * [YAML support](https://github.com/ikatyang/tree-sitter-yaml) active in
    `nvim-treesitter`
  * **Optionally** Telescope

With [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "cuducos/yaml.nvim",
  requires = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim"
  }
}
```

## Usage

The plugin adds some commands, but **no** keymaps (that's on you): `:YAMLView`,
`:YAMLYank`, `:YAMLYank!` and `:YAMLTelescope`.

### Opinionated example

In my setup I create keymaps when I load the plugin. In this example, 
`<Leader>yv` to view the value, `<Leader>YY` to yank it, `<Leader>yy` to yank
just the path, and `<Leader>y` to trigger Telescope:

```lua
use {
  "cuducos/yaml.nvim",
  requires = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim"
  },
  ft = {"yaml"},
  config = function()
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>yv",
        "<Cmd>lua Y.view()<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>YY",
        "<Cmd>lua Y.yank_path()<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>yy",
        "<Cmd>lua Y.yank()<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>y",
        "<Cmd>lua Y.telescope()<CR>",
        { noremap = true, silent = true }
      )
  end
}
```
