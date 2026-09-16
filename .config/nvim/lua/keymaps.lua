local map = vim.keymap.set

-- Remap Space as leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Fast saving and quitting
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })

-- Window navigations 
map("n", "<C-h>", "<C-w>h", { desc = "Focus left pane" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower pane" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper pane" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right pane" })

-- Buffer management 
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Move selected lines up/down in Visual mode
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move lines down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move lines up" })
