local M = {}

function M.setup()
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.expandtab = true
	vim.opt.shiftwidth = 4
	vim.opt.tabstop = 4
	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	-- use the system clipboard for all yanks/deletes/pastes
	vim.opt.clipboard = "unnamedplus"
	-- highlight the current line
	vim.opt.cursorline = true
	-- show a vertical guide at column 120
	vim.opt.colorcolumn = "120"
	-- always show the sign column so text doesn't shift with diagnostics
	vim.opt.signcolumn = "yes"
	-- keep a bit of context around the cursor when scrolling
	vim.opt.scrolloff = 4
	-- enable mouse in all modes
	vim.opt.mouse = "a"
	-- enable truecolor support for themes like Catppuccin
	vim.opt.termguicolors = true
	-- completion: show menu but do not auto-insert or auto-select first item
	vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }

	-- briefly highlight yanked text so it's clear what was copied
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			pcall(vim.highlight.on_yank, { higroup = "Visual", timeout = 150 })
		end,
	})

	-- LSP diagnostics: configure display
	vim.diagnostic.config({
		virtual_text = true, -- inline text next to the line (leave commented if you don't want this)
		signs = true, -- keep the sign column E/W/etc.
		underline = true,
		update_in_insert = false,
		severity_sort = true,
	})
end

return M
