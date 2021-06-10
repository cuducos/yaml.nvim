local pair = require("yaml_nvim.pair")
local M = {}

M.view = function()
  print(pair.parse().as_string)
end

M.init = function()
  vim.cmd("command! YAMLView lua require('yaml_nvim').view()")
end

return M
