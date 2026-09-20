-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Quick insert mode exit
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Move selected text up/down in visual mode with indentation auto-adjusted
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor vertically centered during page jumps and search traversal
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search match and center" })
map("n", "N", "Nzzzv", { desc = "Prev search match and center" })

-- Paste over selection without replacing the clipboard register
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Clear search highlights on pressing Escape
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Ergonomic file save and quit shortcuts
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })
