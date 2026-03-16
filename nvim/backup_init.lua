-- ======================
-- Leader
-- ======================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ======================
-- Basic Options
-- ======================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- ======================
-- Keymaps
-- ======================
local map = vim.keymap.set

map("n", "<leader>v", ":vsplit<CR>")
map("n", "<leader>h", ":split<CR>")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<leader>w", "<cmd>w<cr>" ) 
map("n", "<leader>q", "<cmd>q<cr>" )
map("t", "<Esc>", "<C-\\><C-n>")
map("n", "<C-t>", "<cmd>botright split | terminal<cr><cmd>resize 15<cr>", { desc = "Open terminal bottom" })
map("n", "<leader>t", "<cmd>botright split | terminal<cr><cmd>resize 15<cr>", { desc = "Open terminal bottom" })

-- ======================
-- LSP Keymaps
-- ======================
map("n", "gd", vim.lsp.buf.definition)
map("n", "gr", vim.lsp.buf.references)
map("n", "K",  vim.lsp.buf.hover)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>ca", vim.lsp.buf.code_action)

-- ======================
-- UI Tweaks
-- ======================
vim.opt.cmdheight = 0

vim.notify = function(msg, level)
  if level == vim.log.levels.ERROR then
    vim.cmd("echohl ErrorMsg | echo " .. vim.fn.shellescape(msg) .. " | echohl None")
  end
end
-- ======================
-- Bootstrap lazy.nvim
-- ======================
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

-- ======================
-- Load plugins
-- Lazy auto-discovers all files inside lua/plugins/
-- To disable CP tools, comment out the line in lazy.setup
-- ======================
require("lazy").setup("plugins")
