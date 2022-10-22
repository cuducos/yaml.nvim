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
			return table.concat({ vim.treesitter.query.get_node_text(value, bufnr) }, "\n")
		end

		node = node:parent()
	end
end

local function is_sequence_block(value)
	if value:type() ~= "block_node" then
		return false
	end

	for block_sequence, _ in value:iter_children() do
		return block_sequence:type() == "block_sequence"
	end
end

local function get_sequence_index(block, key)
	for block_sequence, _ in block:iter_children() do
		local index = 0
		for block_sequence_item, _ in block_sequence:iter_children() do
			if ts_utils.is_parent(block_sequence_item, key) then
				return index
			end
			index = index + 1
		end
	end
end

local function get_keys(node, bufnr)
	local keys = {}
	local original = node

	while node ~= nil do
		if node:type() == "block_mapping_pair" then
			local key = node:field("key")[1]
			local key_as_string = vim.treesitter.query.get_node_text(key, bufnr)

			local value = node:field("value")[1]
			if is_sequence_block(value) then
				local index = get_sequence_index(value, original)
				key_as_string = key_as_string .. "[" .. index .. "]"
			end

			table.insert(keys, key_as_string)
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
	local line, _ = node:start()
	local path = vim.api.nvim_buf_get_name(bufnr)
	local cleaned_value = clean_up_block_value(value)
	local human = string.format("%s = %s", key, cleaned_value)

	return {
		key = key,
		cleaned_value = cleaned_value,
		human = human,
		errorformat = string.format("%s:%d: %s", path, line + 1, human),
	}
end

return M
