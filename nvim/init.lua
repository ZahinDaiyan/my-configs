-- =============================================================================
-- Core Neovim Settings
-- Highly optimized, modular configuration bootstrap
-- =============================================================================

-- Set leaders before any plugins are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =============================================================================
-- Global Options
-- =============================================================================
vim.opt.number         = true          -- Show line numbers
vim.opt.relativenumber = true          -- Show relative line numbers for easy jumping
vim.opt.splitright     = true          -- Vertical splits open to the right
vim.opt.splitbelow     = true          -- Horizontal splits open below
vim.opt.termguicolors  = true          -- Enable true color support

vim.opt.expandtab   = true             -- Convert tabs to spaces
vim.opt.tabstop     = 2                -- Number of spaces that a tab stands for
vim.opt.shiftwidth  = 2                -- Number of spaces used for each step of indent
vim.opt.softtabstop = 2                -- Number of spaces in tab when editing

vim.opt.clipboard = "unnamedplus"      -- Share system clipboard
vim.opt.undofile  = true               -- Enable persistent undo across editor restarts

vim.opt.cmdheight = 0                  -- Modern UI: hide command-line unless active

-- =============================================================================
-- Keybindings (Global & Operations)
-- =============================================================================
local map = vim.keymap.set

-- Split window management
map("n", "<leader>v", ":vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>h", ":split<CR>",  { desc = "Split window horizontally" })

-- Standard window navigation switching
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- File save & exit operations
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit editor" })

-- Visual Line Movement: naturally handle wrapped lines
map("n", "j", "gj", { desc = "Move down by visual line" })
map("n", "k", "gk", { desc = "Move up by visual line" })

-- Terminal Escape: smooth exit to normal mode in terminal buffers
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal: escape to normal mode" })

-- Alternate quick bottom terminal toggle fallback
map("n", "<C-t>", "<cmd>botright split | terminal<cr><cmd>resize 15<cr>", { desc = "Open terminal bottom" })

-- =============================================================================
-- LSP Global Buffer Actions
-- =============================================================================
map("n", "gd",         vim.lsp.buf.definition,  { desc = "LSP: Go to definition" })
map("n", "gr",         vim.lsp.buf.references,  { desc = "LSP: Find references" })
map("n", "K",          vim.lsp.buf.hover,       { desc = "LSP: Hover documentation" })
map("n", "<leader>rn", vim.lsp.buf.rename,      { desc = "LSP: Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action" })

-- System Clipboard interaction utilities
map({"n", "v"}, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Copy line to system clipboard" })
map("x", "<leader>p", [["_dP]], { desc = "Paste preserving register" })

-- Visual mode block movement
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Quick window resizing
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- =============================================================================
-- Bootstrap lazy.nvim
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Load Plugins (via Lazy auto-discovery of lua/plugins/)
-- =============================================================================
require("lazy").setup("plugins")
