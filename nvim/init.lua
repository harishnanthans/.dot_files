vim.g.mapleader = " "

-- Configure Augment workspace folders *before* the plugin is loaded.
-- This makes Augment index the project you open Neovim in.
-- You can change this later if you want multiple workspaces.
vim.g.augment_workspace_folders = { vim.loop.cwd() }

-- lazy.nvim bootstrap (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Core settings and keymaps
require("harish.core.options").setup()
require("harish.core.keymaps").setup()

-- Plugin system entrypoint
require("harish.plugins").setup()
