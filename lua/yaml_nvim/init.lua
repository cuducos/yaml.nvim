local document = require("yaml_nvim.document")
local pair = require("yaml_nvim.pair")
local M = {}

M.view = function()
  local node = document.get_key_relevant_to_cursor()
  if node == nil then
    return
  end

  local parsed = pair.parse(node)
  print(parsed.human)
end

M.yank = function(register, key, value)
  if not key and not value then
    return
  end

  local node = document.get_key_relevant_to_cursor()
  if node == nil then
    return
  end

  local parsed = pair.parse(node)
  local contents = ""
  if key and value then
    contents = parsed.human
  elseif key then
    contents = parsed.key
  elseif value then
    contents = parsed.cleaned_value
  end

  vim.cmd(
    string.format(
      "call setreg('%s', '%s')", register, string.gsub(contents, "\'", "\\\'")
    )
  )
end

M.init = function()
  local has_telescope, telescope = pcall(require, "telescope")
  if has_telescope then
    telescope.load_extension("yaml")
  end

  vim.cmd("command! YAMLView lua require('yaml_nvim').view()")
  vim.cmd("command! YAMLYank lua require('yaml_nvim').yank('\"', true, true)")
  vim.cmd(
    "command! YAMLYankKey lua require('yaml_nvim').yank('\"', true, false)"
  )
  vim.cmd(
    "command! YAMLYankValue lua require('yaml_nvim').yank('\"', false, true)"
  )
end

return M
