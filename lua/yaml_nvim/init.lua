local has_telescope, _ = pcall(require, "telescope")
local document = require("yaml_nvim.document")
local pair = require("yaml_nvim.pair")
local M = {}

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

local assure_yaml_filetype = function(func, ...)
	local restore_to = set_yaml_as_filetype()

	func(...)

	restore_filetype(restore_to)
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

	contents = string.gsub(contents, "'", "''")
	contents = string.gsub(contents, "\n", ", ")
	contents = string.gsub(contents, "\r", "")
	vim.fn.setreg(register, contents)
end

M.view = function()
	vim.notify(M.get_yaml_key_and_value())
end

M.get_yaml_key_and_value = function()
	local restore_to = set_yaml_as_filetype()
	local node = document.get_key_relevant_to_cursor()
	if node == nil then
		return
	end
	local parsed = pair.parse(node)
	restore_filetype(restore_to)
	return parsed.human
end

M.yank = function(register)
	assure_yaml_filetype(yank, true, true, register)
end

M.yank_key = function(register)
	assure_yaml_filetype(yank, true, false, register)
end

M.yank_value = function(register)
	assure_yaml_filetype(yank, false, true, register)
end

M.quickfix = function()
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

vim.cmd("command! YAMLView lua require('yaml_nvim').view()")
vim.cmd("command! -nargs=? YAMLYank lua require('yaml_nvim').yank(<f-args>)")
vim.cmd("command! -nargs=? YAMLYankKey lua require('yaml_nvim').yank_key(<f-args>)")
vim.cmd("command! -nargs=? YAMLYankValue lua require('yaml_nvim').yank_value(<f-args>)")
vim.cmd("command! YAMLQuickfix lua require('yaml_nvim').quickfix()")

if has_telescope then
	vim.cmd("command! YAMLTelescope lua require('yaml_nvim').telescope()")
end

return M
