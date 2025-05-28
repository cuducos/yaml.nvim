local spy = require("luassert.spy")
local stub = require("luassert.stub")

describe("Lua functions with sample YAML:", function()
	before_each(function()
		vim.cmd(":e tests/sample.yaml")
		vim.cmd(":norm 12j^")
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

	it("highlight calls the notify function with unknown key", function()
		local matchadelete = stub(vim.fn, "matchdelete")
		local notify = stub(vim, "notify")
		require("yaml_nvim").highlight("this.key.does.not.exist")
		assert.spy(notify).was.called_with("this.key.does.not.exist not found")
		assert.spy(matchadelete).was_not.called()
	end)

	it("highlight calls matchadd with the proper line", function()
		local matchadd = stub(vim.fn, "matchadd")
		require("yaml_nvim").highlight("worldcup.host")
		assert.spy(matchadd).was.called_with("Visual", "\\%2l")
	end)

	it("highlight calls matchadd with the proper lines", function()
		local matchadd = stub(vim.fn, "matchadd")
		require("yaml_nvim").highlight("worldcup.intro")
		assert.spy(matchadd).was.called_with("Visual", "\\%>5l\\%<7l")
	end)

	it("remove_highlight calls matchdelete", function()
		local matchadelete = stub(vim.fn, "matchdelete")
		local yaml = require("yaml_nvim")
		yaml.current_highlight = 42
		yaml.highlight("worldcup.host")
		yaml.remove_highlight()
		assert.spy(matchadelete).was.called_with(42)
		assert.are.equal(nil, yaml.current_highlight)
	end)

	it("snacks calls Snacks's native qflist function", function()
		stub(vim.fn, "setqflist")
		local snacks = require("snacks")
		local qflist = spy.on(snacks.picker, "qflist")
		require("yaml_nvim").snacks()
		assert.spy(qflist).was.called()
	end)

	it("telescope calls Telescope's native quickfix function", function()
		stub(vim.fn, "setqflist")
		local telescope = spy.on(require("telescope.builtin"), "quickfix")
		require("yaml_nvim").telescope()
		assert.spy(telescope).was.called()
	end)

	it("fzf_lua calls fzf-lua's native quickfix function", function()
		stub(vim.fn, "setqflist")
		local fzf_lua = spy.on(require("fzf-lua"), "quickfix")
		require("yaml_nvim").fzf_lua()
		assert.spy(fzf_lua).was.called()
	end)
end)

describe("Lua functions with simple YAML:", function()
	before_each(function()
		vim.cmd("set ft=eruby.yaml")
		vim.cmd(":norm ianswer: 42")
		vim.cmd(":norm oquestion: null")
		vim.cmd(":norm 0d^")
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
				lnum = 1,
				text = "answer = 42",
				valid = 1,
			},
			{
				bufnr = bufnr,
				col = 0,
				lnum = 2,
				text = "question = null",
				valid = 1,
			},
		})
	end)
end)

describe("Lua functions with non-YAML files:", function()
	before_each(function()
		vim.cmd("set ft=lua")
		vim.cmd(":norm iprint(42)")
		vim.cmd(":norm oreturn {}")
	end)

	after_each(function()
		vim.cmd(":bw!")
	end)

	it("loading YAML node ignores filetypes that are not YAML", function()
		local yaml = require("yaml_nvim")
		assert.is_nil(yaml.get_yaml_key_and_value())
		assert.is_nil(yaml.get_yaml_key())
	end)

	it("quickfix ignores filetypes that are not YAML", function()
		local yaml = require("yaml_nvim")
		local setqflist = spy.on(vim.fn, "setqflist")
		yaml.quickfix()
		assert.spy(setqflist).was_not.called()
	end)
end)
