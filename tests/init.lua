local install_from_github = function(uri)
	local repo = string.gsub(uri, "^[^/]+/", "")
	local name = string.gsub(repo, "%p?nvim%p?", "")
	local env = string.upper(name) .. "_DIR"
	local dir = os.getenv(env)
	if dir == nil then
		dir = "/tmp/" .. repo
	end

	if vim.fn.isdirectory(dir) == 0 then
		print(vim.fn.system({ "git", "clone", "https://github.com/" .. uri, dir }))
	end

	vim.opt.rtp:append(dir)
	vim.cmd("runtime plugin/" .. repo)
end

local dependencies = {
	"nvim-lua/plenary.nvim",
	"folke/snacks.nvim",
	"nvim-treesitter/nvim-treesitter",
	"nvim-telescope/telescope.nvim",
}
for _, dep in pairs(dependencies) do
	install_from_github(dep)
end

vim.opt.rtp:append(".")
vim.cmd("runtime plugin/yaml.vim")
vim.cmd("set noswapfile")

require("nvim-treesitter.configs").setup({ ensure_installed = { "yaml" }, sync_install = true })
require("plenary.busted")
