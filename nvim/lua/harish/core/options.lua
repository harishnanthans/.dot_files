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

		-- cursor shape: block in all modes; blinks only in insert/replace, steady in normal/visual
		vim.opt.guicursor = "n-v-c-ve:block,i-ci:block-blinkon500-blinkoff500,r-cr-o:block-blinkon500-blinkoff500"
	-- completion: show menu but do not auto-insert or auto-select first item
	vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }

	-- auto-reload files when changed externally (by AI tools, git, etc.)
	vim.opt.autoread = true

	-- Disable swap files and backup files to avoid conflicts with external changes
	vim.opt.swapfile = false
	vim.opt.backup = false
	vim.opt.writebackup = false

	-- Reduce updatetime for faster detection of external changes (default is 4000ms)
	vim.opt.updatetime = 250

	-- briefly highlight yanked text so it's clear what was copied
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			pcall(vim.highlight.on_yank, { higroup = "Visual", timeout = 150 })
		end,
	})

	-- auto-reload: check for external changes when focus returns or buffer is entered
	local auto_reload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })

	vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
		group = auto_reload_group,
		callback = function()
			if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == "" then
				vim.cmd("checktime")
			end
		end,
	})

	-- Notify when file changes externally
	vim.api.nvim_create_autocmd("FileChangedShellPost", {
		group = auto_reload_group,
		callback = function()
			vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
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
