describe("commands", function()
	it("yanks key to the default register", function()
		require("yaml_nvim")

		vim.cmd(":e sample.yaml")
		vim.cmd(":YAMLYankKey")

		assert(vim.fn.getreg('"'), "worldcup")
	end)

	it("yanks key to a custom register", function()
		require("yaml_nvim")

		vim.cmd(":e sample.yaml")
		vim.cmd(":YAMLYankKey 7")

		assert(vim.fn.getreg("7"), "worldcup")
	end)

	it("yanks value to the default register", function()
		require("yaml_nvim")

		vim.cmd(":e sample.yaml")
		vim.cmd("norm 10j")
		vim.cmd(":YAMLYankValue")

		assert(vim.fn.getreg('"'), "7")
	end)

	it("yanks value to a custom register", function()
		require("yaml_nvim")

		vim.cmd(":e sample.yaml")
		vim.cmd("norm 10j")
		vim.cmd(":YAMLYankValue 7")

		assert(vim.fn.getreg("7"), "7")
	end)
end)
