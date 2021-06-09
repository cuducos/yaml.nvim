local ts_utils = require("nvim-treesitter.ts_utils")
local M = {} -- a namespace for this module

local function reverse(keys)
  local n = #keys
  local i = 1
  while i < n do
    keys[i], keys[n] = keys[n], keys[i]
    i = i + 1
    n = n - 1
  end
end

local function get_value(node, bufnr)
  while node ~= nil do
    if node:type() == "block_mapping_pair" then
      return ts_utils.get_node_text(node:field("value")[1], bufnr)[1]
    end

    node = node:parent()
  end
end

local function get_keys(node, bufnr)
  local keys = {}

  while node ~= nil do
    if node:type() == "block_mapping_pair" then
      table.insert(keys, ts_utils.get_node_text(node:field("key")[1], bufnr)[1])
    end

    node = node:parent()
  end

  reverse(keys)
  return table.concat(keys, ".")
end

local function parse()
  local bufnr = vim.api.nvim_get_current_buf()
  local node = ts_utils.get_node_at_cursor(nil)
  return {key = get_keys(node, bufnr), value = get_value(node, bufnr)}
end

M.view = function()
  local node = parse()
  print(string.format("%s = %s", node["key"], node["value"]))
end

M.init = function()
  vim.cmd("command! YAMLView lua require('yaml_nvim').view()")
end

return M
