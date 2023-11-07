local has_telescope, _ = pcall(require, "telescope")
local document = require("yaml_nvim.document")
local pair = require("yaml_nvim.pair")

local is_yaml = function()
	local curr = vim.bo.filetype
	for _, ft in ipairs(M.config.ft) do
		if curr == ft then
			return true
		end
	end

	return false
end

local set_yaml_as_filetype = function()
	local expected = "yaml"
	local restore_to = nil

	if vim.bo.filetype ~= expected then
		restore_to = vim.bo.filetype
		vim.bo.filetype = expected
	end

	return restore_to
end

local restore_filetype = function(restore_to)
	if restore_to ~= nil then
		vim.bo.filetype = restore_to
	end
end

local get_current_yaml_node = function()
	if not is_yaml() then
		return
	end

	local restore_to = set_yaml_as_filetype()

	local node = document.get_key_relevant_to_cursor()
	if node == nil then
		return
	end
	local parsed = pair.parse(node)

	restore_filetype(restore_to)

	return parsed
end

local yank = function(node, key, value, register)
	if node == nil then
		return
	end

	register = register or [["]]
	if not key and not value then
		return
	end

	local contents = ""
	if key and value then
		contents = node.human
	elseif key then
		contents = node.key
	elseif value then
		contents = node.cleaned_value
	end

	contents = string.gsub(contents, "'", "''")
	contents = string.gsub(contents, "\n", ", ")
	contents = string.gsub(contents, "\r", "")
	vim.fn.setreg(register, contents)
end

-- Public API

M = {}

M.default_config = {
	ft = { "yaml", "eruby.yaml" },
}

M.config = vim.deepcopy(M.default_config)

M.setup = function(opts)
	if opts == nil then
		return
	end

	for k, _ in pairs(M.default_config) do
		local custom = opts[k]
		if custom ~= nil then
			M.config[k] = custom
		end
	end
end

M.view = function()
	local node = get_current_yaml_node()
	if node == nil then
		return
	end

	vim.notify(node.human)
end

M.get_yaml_key_and_value = function()
	local node = get_current_yaml_node()
	if node == nil then
		return
	end

	return node.human
end

M.get_yaml_key = function()
	local node = get_current_yaml_node()
	if node == nil then
		return
	end
	return node.key
end

M.yank = function(register)
	yank(get_current_yaml_node(), true, true, register)
end

M.yank_key = function(register)
	yank(get_current_yaml_node(), true, false, register)
end

M.yank_value = function(register)
	yank(get_current_yaml_node(), false, true, register)
end

M.quickfix = function()
	if not is_yaml() then
		return
	end

	local restore_to = set_yaml_as_filetype()
	local lines = {}

	for _, key in pairs(document.all_keys()) do
		if not document.is_value_a_block(key) then
			local parsed = pair.parse(key)
			table.insert(lines, parsed.quickfix)
		end
	end

	restore_filetype(restore_to)
	vim.fn.setqflist(lines)
end

M.telescope = function()
	if not has_telescope then
		return
	end

	M.quickfix()
	require("telescope.builtin").quickfix()
end

-- Commands

vim.cmd("command! YAMLView lua require('yaml_nvim').view()")
vim.cmd("command! -nargs=? YAMLYank lua require('yaml_nvim').yank(<f-args>)")
vim.cmd("command! -nargs=? YAMLYankKey lua require('yaml_nvim').yank_key(<f-args>)")
vim.cmd("command! -nargs=? YAMLYankValue lua require('yaml_nvim').yank_value(<f-args>)")
vim.cmd("command! YAMLQuickfix lua require('yaml_nvim').quickfix()")

if has_telescope then
	vim.cmd("command! YAMLTelescope lua require('yaml_nvim').telescope()")
end

return M
