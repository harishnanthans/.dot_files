local M = {}

function M.setup()
	local map = vim.keymap.set
	local opts = { silent = true }

	map("n", "<leader>w", ":w<CR>", opts)
	-- Augment: enable/disable completions globally (no longer uses deprecated commands)
	map("n", "<leader>ae", "<cmd>let g:augment_disable_completions = v:false<CR>", opts)
	map("n", "<leader>ad", "<cmd>let g:augment_disable_completions = v:true<CR>", opts)
	-- Clear search highlight when pressing ESC in normal mode
	map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", opts)

	-- Manual reload: force reload current buffer from disk
	map("n", "<leader>r", "<cmd>edit!<CR>", { desc = "Reload buffer from disk" })

	-- Split navigation with Ctrl + h/j/k/l
	map("n", "<C-h>", "<C-w>h", opts)
	map("n", "<C-j>", "<C-w>j", opts)
	map("n", "<C-k>", "<C-w>k", opts)
	map("n", "<C-l>", "<C-w>l", opts)

	map("n", "<Tab>", "<C-^>", { desc = "Switch to last buffer" })

	map("n", "<leader>|", ":vsplit<CR>", opts)
	map("n", "<leader>_", ":split<CR>", opts)
end

return M
