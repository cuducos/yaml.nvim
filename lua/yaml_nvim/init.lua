local has_telescope, _ = pcall(require, "telescope")
local document = require("yaml_nvim.document")
local pair = require("yaml_nvim.pair")
local M = {}

-- created in _G so we can call it with v:lua
_G.create_yaml_quickfix = function()
  local lines = {}
  for _, key in pairs(document.all_keys()) do
    if not document.is_value_a_block(key) then
      local parsed = pair.parse(key)
      table.insert(lines, parsed.errorformat)
    end
  end

  return lines
end

local yank = function(key, value, register)
  register = register or [["]]
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

  contents = string.gsub(contents, "\'", "\\\'")
  vim.cmd(string.format("call setreg('%s', '%s')", register, contents))
end

M.view = function()
  local node = document.get_key_relevant_to_cursor()
  if node == nil then
    return
  end

  local parsed = pair.parse(node)
  vim.notify(parsed.human)
end

M.yank_all = function(register)
  yank(true, true, register)
end

M.yank_key = function(register)
  yank(true, false, register)
end

M.yank_value = function(register)
  yank(false, true, register)
end

M.telescope = function()
  if not has_telescope then
    return
  end
  vim.cmd("cex v:lua.create_yaml_quickfix()")
  require("telescope.builtin").quickfix()
end

vim.cmd("command! YAMLView lua require('yaml_nvim').view()")
vim.cmd(
  "command! -nargs=? YAMLYank lua require('yaml_nvim').yank_all(<f-args>)"
)
vim.cmd(
  "command! -nargs=? YAMLYankKey lua require('yaml_nvim').yank_key(<f-args>)"
)
vim.cmd(
  "command! -nargs=? YAMLYankValue lua require('yaml_nvim').yank_value(<f-args>)"
)
vim.cmd("command! YAMLQuickfix cex v:lua.create_yaml_quickfix()")

if has_telescope then
  vim.cmd("command! YAMLTelescope lua require('yaml_nvim').telescope()")
end

return M
