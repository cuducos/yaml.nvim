local M = {}

local function get_keys(root)
	local keys = {}
	for node, name in root:iter_children() do
		if name == "key" then
			table.insert(keys, node)
		end

		if node:child_count() > 0 then
			for _, child in pairs(get_keys(node)) do
				table.insert(keys, child)
			end
		end
	end
	return keys
end

M.is_value_a_block = function(key)
	for node, name in key:parent():iter_children() do
		if name == "value" then
			if node:type() ~= "block_node" then
				return false
			else
				return node:child():type() ~= "block_scalar"
			end
		end
	end
	return true
end

M.all_keys = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_buf_get_option(bufnr, "ft")
	local tree = vim.treesitter.get_parser(bufnr, ft):parse()[1]
	local root = tree:root()
	return get_keys(root)
end

M.get_key_relevant_to_cursor = function()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local previous_node = nil

	for _, node in pairs(M.all_keys()) do
		local node_line, _ = node:start()
		node_line = node_line + 1

		if cursor_line == node_line then
			return node
		end

		if cursor_line < node_line then
			return previous_node
		end

		previous_node = node
	end
end

return M
