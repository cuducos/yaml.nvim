local load_cmds = function()
	local cmds = {}
	for _, cmd in pairs(vim.api.nvim_get_commands({})) do
		table.insert(cmds, cmd.name)
	end
	return cmds
end

local contains = function(tbl, item)
	for _, value in pairs(tbl) do
		if value == item then
			return true
		end
	end
	return false
end

describe("setup", function()
	it("loads the lua module", function()
		local yaml = require("yaml_nvim")
		assert(yaml ~= nil, [[expected require("yaml_nvim") not to be nil, got nil]])
	end)

	it("makes commands available", function()
		require("yaml_nvim")

		local expected = {
			"YAMLView",
			"YAMLYank",
			"YAMLYankKey",
			"YAMLYankValue",
			"YAMLQuickfix",
		}

		local cmds = load_cmds()
		for _, cmd in pairs(expected) do
			assert(contains(cmds, cmd), cmd .. " not found")
		end
	end)
end)
