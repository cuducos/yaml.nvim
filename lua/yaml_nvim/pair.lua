local M = {}

-- ported from nvim-treestter master branch (to be deprecated)
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/42fc28ba918343ebfd5565147a42a26580579482/lua/nvim-treesitter/ts_utils.lua#L72-L90
function is_parent(dest, source)
	if not (dest and source) then
		return false
	end
	local current = source
	while current ~= nil do
		if current == dest then
			return true
		end
		current = current:parent()
	end
	return false
end

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
	if value == nil then
		return
	end
	value = string.gsub(value, "\n", " ")

	if value:sub(1, 1) ~= "|" then
		return value
	end

	return trim(string.gsub(value:sub(2, #value), "%s+", " "))
end

local function get_value_node(node)
	while node ~= nil do
		if node:type() == "block_mapping_pair" then
			if node:field("value")[1] ~= nil then
				return node
			end
		end
		node = node:parent()
	end
end

local function get_value(node, bufnr)
	if node == nil then
		return ""
	end
	local value = node:field("value")[1]
	return table.concat({ vim.treesitter.get_node_text(value, bufnr) }, "\n")
end

local function is_sequence_block(value)
	if value then
		if value:type() ~= "block_node" then
			return false
		end

		for block_sequence, _ in value:iter_children() do
			return block_sequence:type() == "block_sequence"
		end
	else
		return false
	end
end

local function get_sequence_index(block, key)
	for block_sequence, _ in block:iter_children() do
		local index = 0
		for block_sequence_item, _ in block_sequence:iter_children() do
			if is_parent(block_sequence_item, key) then
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
			local key_as_string = vim.treesitter.get_node_text(key, bufnr)

			local value = node:field("value")[1]
			if is_sequence_block(value) then
				local index = get_sequence_index(value, original)
				if index ~= nil then
					key_as_string = key_as_string .. "[" .. index .. "]"
				end
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
	local value_node = get_value_node(node)
	local value = get_value(value_node, bufnr)
	local cleaned_value = clean_up_block_value(value)
	local human = string.format("%s = %s", key, cleaned_value)
	local start_line, start_col = node:start()
	local end_line = start_line
	if value_node ~= nil then
		end_line, _ = value_node:end_()
	end

	return {
		key = key,
		cleaned_value = cleaned_value,
		human = human,
		lines = { start_line + 1, end_line + 1 },
		quickfix = {
			bufnr = bufnr,
			col = start_col,
			lnum = start_line + 1,
			text = human,
			valid = 1,
		},
	}
end

return M
