-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Low-level assembly filetype associations
vim.filetype.add({
  extension = {
    nasm = "asm",
  },
})

-- Auto-organize imports for Python files using Ruff
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("RuffAutoOrganize", { clear = true }),
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" } },
      apply = true,
    })
  end,
})

-- Automatically create parent directories when saving a file if they don't exist
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("AutoCreateDir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = (vim.uv or vim.loop).fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
