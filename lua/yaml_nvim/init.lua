local document = require("yaml_nvim.document")
local pair = require("yaml_nvim.pair")
local M = {}

M.view = function()
  print(pair.parse(document.get_key_relevant_to_cursor()).as_string)
end

M.init = function()
  local has_telescope, telescope = pcall(require, "telescope")
  if has_telescope then
    telescope.load_extension("yaml")
  end

  vim.cmd("command! YAMLView lua require('yaml_nvim').view()")
end

return M
