local install_from_github = function(repo, dir)
	local is_not_a_directory = vim.fn.isdirectory(dir) == 0
	if is_not_a_directory then
		print(vim.fn.system({ "git", "clone", "https://github.com/" .. repo, dir }))
	end
	vim.opt.rtp:append(dir)
end

local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local treesitter_dir = os.getenv("TREESITTER_DIR") or "/tmp/nvim-treesitter"

install_from_github("nvim-lua/plenary.nvim", plenary_dir)
install_from_github("nvim-treesitter/nvim-treesitter", treesitter_dir)

vim.opt.rtp:append(".")
vim.cmd("runtime plugin/plenary.vim")
vim.cmd("runtime plugin/nvim-treesitter")
vim.cmd("runtime plugin/yaml.vim")

require("nvim-treesitter.configs").setup({ ensure_installed = { "yaml" }, sync_install = true })
require("plenary.busted")
