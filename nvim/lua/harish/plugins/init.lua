-- Plugin specification / setup lives here.
-- lazy.nvim is bootstrapped in init.lua, we just tell it about plugins.

local M = {}

function M.setup()
	require("lazy").setup({
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			config = function()
				vim.cmd.colorscheme("catppuccin-mocha")
			end,
		},
		{
			"stevearc/oil.nvim",
			-- Use oil as the default file explorer so opening a directory (e.g. `nvim .`)
			-- shows the same interface as pressing `-` inside a file.
			lazy = false,
			opts = {
				default_file_explorer = true,
				view_options = {
					show_hidden = true,
				},
			},
			keys = {
				{ "-", "<CMD>Oil<CR>", desc = "Open parent directory (oil)" },
			},
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{
			"mbbill/undotree",
			keys = {
				{ "<leader>u", "<CMD>UndotreeToggle<CR>", desc = "Toggle undo tree" },
			},
		},
		{
			"nvim-telescope/telescope.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
            pickers = {
                find_files = {
                    hidden = true
                }
            },
			keys = {
				{
					"<leader>sf",
					function()
						require("telescope.builtin").find_files()
					end,
					desc = "Find files",
				},
				{
					"<leader>sg",
					function()
						require("telescope.builtin").live_grep()
					end,
					desc = "Live grep",
				},
				{
					"<leader>ss",
					function()
						require("telescope.builtin").treesitter()
					end,
					desc = "Symbols (Treesitter)",
				},
				{
					"<leader>sh",
					function()
						require("telescope.builtin").help_tags()
					end,
					desc = "Help tags",
				},
				{
					"<leader><leader>",
					function()
						require("telescope.builtin").buffers()
					end,
					desc = "Switch buffer",
				},
					{
						"<leader>/",
						function()
							require("telescope.builtin").current_buffer_fuzzy_find()
						end,
						desc = "Search in current buffer",
					},
					-- LSP + Telescope pickers
					{
						"<leader>ls",
						function()
							require("telescope.builtin").lsp_document_symbols()
						end,
						desc = "LSP: symbols in file",
					},
					-- {
					-- 	"<leader>lS",
					-- 	function()
					-- 		require("telescope.builtin").lsp_workspace_symbols()
					-- 	end,
					-- 	desc = "LSP: symbols in workspace",
					-- },
					{
						"gr",
						function()
							require("telescope.builtin").lsp_references()
						end,
						desc = "LSP: references",
					},
			},
		},
			{
				"folke/which-key.nvim",
				event = "VeryLazy",
				config = function()
					local wk = require("which-key")
					wk.setup()
				end,
			},
		-- LSP: native Neovim LSP with mason for managing servers (gopls only for now)
		{
			"williamboman/mason.nvim",
			lazy = false,
			config = function()
				require("mason").setup()
			end,
		},
		{
			"neovim/nvim-lspconfig",
			lazy = false,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			lazy = false,
			dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
			config = function()
				local mason_lspconfig = require("mason-lspconfig")
				mason_lspconfig.setup({
					ensure_installed = { "gopls" },
				})

				-- advertise completion capabilities to LSP servers (for nvim-cmp)
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
				if ok_cmp then
					capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
				end

				local function on_attach(_, bufnr)
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
					end

					-- basic LSP navigation
					map("n", "gd", vim.lsp.buf.definition, "LSP: goto definition")
					map("n", "gD", vim.lsp.buf.declaration, "LSP: goto declaration")
					map("n", "gI", vim.lsp.buf.implementation, "LSP: goto implementation")

					-- use gR (not gr) so we do not conflict with Treesitter's grn/grm/grc
					local function lsp_references()
						local ok, builtin = pcall(require, "telescope.builtin")
						if ok then
							builtin.lsp_references()
						else
							vim.lsp.buf.references()
						end
					end
					map("n", "gR", lsp_references, "LSP: references")

					-- hover docs
					map("n", "K", vim.lsp.buf.hover, "LSP: hover")

					-- rename & code actions
					map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")

					-- diagnostics
					map("n", "[d", vim.diagnostic.goto_prev, "LSP: prev diagnostic")
					map("n", "]d", vim.diagnostic.goto_next, "LSP: next diagnostic")
					map("n", "<leader>e", vim.diagnostic.open_float, "LSP: line diagnostics")
				end

				-- Modern Neovim 0.11+ LSP API (no deprecated require('lspconfig') framework)
				if vim.lsp and vim.lsp.config and vim.lsp.enable then
					vim.lsp.config("gopls", {
						on_attach = on_attach,
						capabilities = capabilities,
					})
					vim.lsp.enable("gopls")
				else
					-- Fallback for older Neovim: use the old nvim-lspconfig API if available
					local ok, lspconfig = pcall(require, "lspconfig")
					if ok then
						lspconfig.gopls.setup({
							on_attach = on_attach,
							capabilities = capabilities,
						})
					end
				end
			end,
		},
		{
			"stevearc/conform.nvim",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				local conform = require("conform")

				conform.setup({
					-- Choose formatter(s) per filetype
					formatters_by_ft = {
						go = { "gofmt" }, -- Go: use gofmt (comes with Go)
					},
					-- IMPORTANT: do NOT enable format-on-save; you only format on keypress
					format_on_save = false,
				})

				-- <leader>f: format file (normal) or selection (visual)
				vim.keymap.set({ "n", "v" }, "<leader>f", function()
					conform.format({
						lsp_fallback = true, -- if no external formatter, try LSP
						async = false,
						timeout_ms = 5000,
					})
				end, { desc = "Format file or selection" })
			end,
		},
			{
				"lewis6991/gitsigns.nvim",
				event = { "BufReadPre", "BufNewFile" },
				config = function()
					local gitsigns = require("gitsigns")
					gitsigns.setup()

					local map = vim.keymap.set
					-- Hunk navigation
					map("n", "]h", gitsigns.next_hunk, { desc = "Next git hunk" })
					map("n", "[h", gitsigns.prev_hunk, { desc = "Previous git hunk" })
					-- Hunk actions
					map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Git: stage hunk" })
					map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Git: reset hunk" })
					map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Git: preview hunk" })
				end,
			},
			{
				"tpope/vim-fugitive",
				cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite" },
				keys = {
					{ "<leader>gs", "<cmd>G<CR>", desc = "Git status (Fugitive)" },
					{ "<leader>gd", "<cmd>Gvdiffsplit!<CR>", desc = "Git 3-way diff (conflicts)" },
				},
			},
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"L3MON4D3/LuaSnip",
				"saadparwaiz1/cmp_luasnip",
			},
			config = function()
				local cmp = require("cmp")
				local luasnip = require("luasnip")

				cmp.setup({
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						["<C-n>"] = cmp.mapping.select_next_item(),
						["<C-p>"] = cmp.mapping.select_prev_item(),
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-e>"] = cmp.mapping.abort(),
						["<CR>"] = cmp.mapping.confirm({ select = false }),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "buffer" },
						{ name = "path" },
					}),
				})
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			lazy = false, -- plugin itself should not be lazy-loaded
		},
		{
			"MeanderingProgrammer/treesitter-modules.nvim",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			---@type ts.mod.UserConfig
			opts = {
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"bash",
					"markdown",
					"markdown_inline",
					"javascript",
					"typescript",
					"json",
					"python",
					"go",
					"rust",
					"cpp",
					"java",
				},
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = { enable = true },
			},
		},
			{
				"MeanderingProgrammer/render-markdown.nvim",
				ft = { "markdown" },
				keys = {
					{ "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Markdown render" },
				},
				dependencies = {
					"nvim-treesitter/nvim-treesitter",
					"nvim-tree/nvim-web-devicons",
				},
				opts = {},
			},
			-- Augment: AI suggestions and chat for your workspace
			{
				"augmentcode/augment.vim",
			},
	})
end

return M
