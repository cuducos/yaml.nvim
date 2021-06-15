local ts_utils = require("nvim-treesitter.ts_utils")
local document = require("yaml_nvim.document")
local M = {}

local function trim(value)
  return (value:gsub("^%s*(.-)%s*$", "%1"))
end

local function reverse(keys)
  local n = #keys
  local i = 1
  while i < n do
    keys[i], keys[n] = keys[n], keys[i]
    i = i + 1
    n = n - 1
  end
end

local function clean_up_block_value(value)
  if value:sub(1, 1) ~= "|" then
    return value
  end

  return trim(string.gsub(value:sub(2, #value), "%s+", " "))
end

local function get_value(node, bufnr)
  while node ~= nil do
    if node:type() == "block_mapping_pair" then
      local value = node:field("value")[1]
      return table.concat(ts_utils.get_node_text(value, bufnr), "\n")
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

M.parse = function(node)
  local bufnr = vim.api.nvim_get_current_buf()
  local key = get_keys(node, bufnr)
  local value = get_value(node, bufnr)
  local line, column = node:start()
  local path = vim.api.nvim_buf_get_name(bufnr)
  local human = string.format("%s = %s", key, clean_up_block_value(value))

  return {
    key = key,
    value = value,
    human = human,
    line = line + 1,
    column = column,
    path = path,
    errorformat = string.format("%s:%d: %s", path, line, human),
  }
end

return M
