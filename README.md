# yaml.nvim [![Tests status](https://github.com/cuducos/yaml.nvim/actions/workflows/tests.yml/badge.svg)](https://github.com/cuducos/yaml.nvim/actions/workflows/tests.yml)

Simple tools to help developers working YAML in [Neovim](https://neovim.io).

Assuming `yaml = require("yaml_nvim")` for the Lua API:

| Command | Lua API | Description |
|:--|:--|:--|
| `:YAMLView` | `yaml.view()` | Shows the full path and value of the current key/value pair |
| `:YAMLYank [register]` | `yaml.yank_all([register])` | Yanks the full path and value of the current key/value pair. The default register is the unnamed one (`"`) |
| `:YAMLYankKey [register]` | `yaml.yank_key([register])`  | Yanks the full path of the key for the current key/value pair. The default register is the unnamed one (`"`) |
| `:YAMLYankValue [register]` | `yaml.yank_value([register])`  | Yanks the value of the current key/value pair. The default register is the unnamed one (`"`) |
| `:YAMLQuickfix` | `yaml.quickfix()` | Generates a quickfix with key/value pairs |
| `:YAMLSnacks` | `yaml.snacks()` | Full path key/value fuzzy finder via [Snacks](https://github.com/folke/snacks.nvim) **if installed** |
| `:YAMLTelescope` | `yaml.telescope()`  | Full path key/value fuzzy finder via [Telescope](https://github.com/nvim-telescope/telescope.nvim) **if installed** |

![Example GIF](doc/demo.gif)

## Requirements

* **Neovim 0.9** or newer
* [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) with [YAML support](https://github.com/ikatyang/tree-sitter-yaml)

Snacks and Telescope are **optional**.

<details>

<summary>What about older versions of Neovim?</summary>

* For **Neovim 0.7 or 0.8**, pin to [`7925bd2`](https://github.com/cuducos/yaml.nvim/commit/7925bd2bf03c718996ccad7e1a49eafe40cd3246)
* For **Neovim 0.5 or 0.6**, pin to [`155c23d`](https://github.com/cuducos/yaml.nvim/commit/155c23de8f99fdb424f8aa713bcb993cc2538c6c)

 </details>

## Install

### With [`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
{
  "cuducos/yaml.nvim",
  ft = { "yaml" }, -- optional
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim", -- optional
    "nvim-telescope/telescope.nvim", -- optional
  },
}
```

### With [`packer.nvim`](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "cuducos/yaml.nvim",
  ft = { "yaml" }, -- optional
  requires = {
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim", -- optional
    "nvim-telescope/telescope.nvim" -- optional
  },
}
```

### With [`vim-plug`](https://github.com/junegunn/vim-plug):

```viml
Plug 'folke/snacks.nvim' " optional
Plug 'nvim-telescope/telescope.nvim' " optional
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'cuducos/yaml.nvim'
```

### No YAML parser?

If you get a <code>no parser for 'yaml' language</code> error message, this means that you need to install a parser such as [`tree-sitter-yaml`](https://github.com/ikatyang/tree-sitter-yaml). If that is the case, you need to enable it in your config.

<details>

<summary>Here is an example, using <code>lazy.nvim</code></summary>

```lua
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "yaml" },
      },
  })
  end,
}
```

</details>

## Configuration

### File types

The plugin ignores other file types than YAML. By now the list of YAML file types includes `yaml` and `eruby.yaml` — we're are open to enhance this list, so PRs are welcomed.

If you want to manually change this list, you can pass a custom config:

```lua
require("yaml_nvim").setup({ ft = { "yaml",  "other yaml filetype" } })
```

### Showing the YAML path and value

#### Neovim's winbar

```lua
vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
  pattern = { "*.yaml" },
  callback = function()
    vim.opt_local.winbar = require("yaml_nvim").get_yaml_key_and_value()
  end,
})
```

You can also call `get_yaml_key()` instead of `get_yaml_key_and_value()` to show only the YAML key.

<details>

<summary>For non-named buffers</summary>

See [#33](https://github.com/cuducos/yaml.nvim/pull/33), for example:

```lua
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("bufent_winbar", { clear = true }),
  callback = function(opts)
    if vim.bo[opts.buf].filetype == "yaml" then
      vim.api.nvim_create_autocmd({ "CursorMoved" }, {
        group = vim.api.nvim_create_augroup("curs_winbar", { clear = true }),
        callback = function()
          vim.opt_local.winbar = require("yaml_nvim").get_yaml_key_and_value()
        end,
      })
    else
      vim.opt_local.winbar = ""
      vim.api.nvim_create_augroup("curs_winbar", { clear = true })
    end
  end,
})
```

</details>

#### Neovim's statusline (with [`lualine.nvim`](https://github.com/nvim-lualine/lualine.nvim))

```lua
require("lualine").setup({
  sections = {
    lualine_x = { require("yaml_nvim").get_yaml_key_and_value },
    -- etc
  }
})
```

## Reporting bugs and contributing

There is a mini toolchain to help you test the plugin in isolation using a container. It requires:

* [Lua](https://www.lua.org/)
* [Docker](https://www.docker.com/) or [Podman](https://podman.io/)

| Command | Description |
|---|---|
| `./manage build` | Builds the container |
| `./manage test` | Runs the tests inside the container |
| `./manage nvim` | Opens the container's Neovim with a sample YAML file |
