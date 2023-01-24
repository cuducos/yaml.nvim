local install = function(repo, dir)
	local is_not_a_directory = vim.fn.isdirectory(dir) == 0
	if is_not_a_directory then
		print(vim.fn.system({ "git", "clone", repo, dir }))
	end
	vim.opt.rtp:append(dir)
end

local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local treesitter_dir = os.getenv("TREESITTER_DIR") or "/tmp/nvim-treesitter"

install("https://github.com/nvim-lua/plenary.nvim", plenary_dir)
install("https://github.com/nvim-treesitter/nvim-treesitter", treesitter_dir)

vim.opt.rtp:append(".")
vim.cmd("runtime plugin/plenary.vim")
vim.cmd("runtime plugin/nvim-treesitter")
vim.cmd("runtime plugin/yaml.vim")
require("plenary.busted")
