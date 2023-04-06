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
end)
