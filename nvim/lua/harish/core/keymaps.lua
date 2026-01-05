local M = {}

function M.setup()
	  local map = vim.keymap.set
	  local opts = { silent = true }

	  map("n", "<leader>w", ":w<CR>", opts)
	  -- Clear search highlight when pressing ESC in normal mode
	  map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", opts)

	  -- Split navigation with Ctrl + h/j/k/l
	  map("n", "<C-h>", "<C-w>h", opts)
	  map("n", "<C-j>", "<C-w>j", opts)
	  map("n", "<C-k>", "<C-w>k", opts)
	  map("n", "<C-l>", "<C-w>l", opts)
end

return M

