return {
  -- 1. Tokyo Night Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "storm" })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- 2. Which-Key (Keybinding Discoverability)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- 3. Treesitter (Syntax Highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { 
            "asm",
            "c",
            "cmake",
            "cpp",
            "disassembly",
            "dockerfile",
            "git_config",
            "git_rebase",
            "gitattributes",
            "gitcommit",
            "gitignore",
            "go",
            "java",
            "llvm",
            "lua",
            "bash",
            "make",
            "markdown",
            "ninja",
            "objdump",
            "python",
            "json",
            "ssh_config",
            "rust",
            "toml",
            "vim",
            "vimdoc",
            "yaml",
        },
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- 4. Telescope (Fuzzy Finder over fd and ripgrep)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep (ripgrep)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List Open Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/" },
      },
    },
  },

  -- 5. Native Language Server Protocol (LSP) Engine
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Diagnostic styling
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
      })

      -- Keybindings attached only when a language server connects
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
}
