local spy = require("luassert.spy")
local stub = require("luassert.stub")

describe("Lua functions with sample YAML:", function()
	before_each(function()
		vim.cmd(":e tests/sample.yaml")
		vim.cmd("set ft=not-a-yaml-file")
		vim.cmd(":norm 10j^")
	end)

	after_each(function()
		vim.cmd(":bw!")
	end)

	it("view calls the notify function with the human-readable text", function()
		local notify = stub(vim, "notify")
		require("yaml_nvim").view()
		assert.spy(notify).was.called_with("worldcup.semifinals[0].germany = 7")
	end)

	it("get_yaml_key_and_value returns the human-readable text", function()
		local got = require("yaml_nvim").get_yaml_key_and_value()
		assert.are.equal("worldcup.semifinals[0].germany = 7", got)
	end)

	it("get_yaml_key returns the concatenated key value", function()
		local got = require("yaml_nvim").get_yaml_key()
		assert.are.equal("worldcup.semifinals[0].germany", got)
	end)

	it("yank puts the human-readable text in the default register", function()
		require("yaml_nvim").yank()
		assert.are.equal("worldcup.semifinals[0].germany = 7", vim.fn.getreg('"'))
	end)

	it("yank puts the human-readable text in a custom register", function()
		require("yaml_nvim").yank(7)
		assert.are.equal("worldcup.semifinals[0].germany = 7", vim.fn.getreg("7"))
	end)

	it("yank_key puts the concatenated key value in the default register", function()
		require("yaml_nvim").yank_key()
		assert.are.equal("worldcup.semifinals[0].germany", vim.fn.getreg('"'))
	end)

	it("yank_key puts the concatenated key value in a custom register", function()
		require("yaml_nvim").yank_key(7)
		assert.are.equal("worldcup.semifinals[0].germany", vim.fn.getreg("7"))
	end)

	it("yank_value puts the YAML value in the default register", function()
		require("yaml_nvim").yank_value()
		assert.are.equal("7", vim.fn.getreg('"'))
	end)

	it("yank_value puts the YAML value in a custom register", function()
		require("yaml_nvim").yank_value(7)
		assert.are.equal("7", vim.fn.getreg("7"))
	end)

	it("telescope calls Telescope's native quickfix function", function()
		stub(vim.fn, "setqflist")
		local telescope = spy.on(require("telescope.builtin"), "quickfix")
		require("yaml_nvim").telescope()
		assert.spy(telescope).was.called()
	end)
end)

describe("Lua functions with simple YAML:", function()
	before_each(function()
		vim.cmd("set ft=not-a-yaml-file")
		vim.cmd(":norm ianswer: 42")
		vim.cmd(":norm oquestion: null")
	end)

	after_each(function()
		vim.cmd(":bw!")
	end)

	it("quickfix calls native setqflist with human-readable lines", function()
		local setqflist = spy.on(vim.fn, "setqflist")
		local bufnr = vim.api.nvim_get_current_buf()
		require("yaml_nvim").quickfix()
		assert.spy(setqflist).was.called_with({
			{
				bufnr = bufnr,
				col = 0,
				lnum = 0,
				text = "answer = 42",
				valid = 1,
			},
			{
				bufnr = bufnr,
				col = 0,
				lnum = 1,
				text = "question = null",
				valid = 1,
			},
		})
	end)
end)
