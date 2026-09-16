return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            auto_install = false,
            ensure_installed = {
                -- Systems, Compilers & Low-Level / Reverse Engineering
                "c",
                "cpp",
                "asm",
                "llvm",
                "objdump",
                "doxygen",
                "cuda",

                -- Core Programming Languages
                "python",
                "rust",
                "go",
                "gomod",
                "gosum",
                "gowork",
                "zig",
                "lua",
                "luadoc",
                "java",
                "c_sharp",
                "ruby",
                "php",
                "javascript",
                "typescript",

                -- Build Systems & Tooling
                "make",
                "cmake",
                "ninja",
                "meson",

                -- Shell, Containers & Terminal
                "bash",
                "dockerfile",

                -- Git Ecosystem
                "git_config",
                "git_rebase",
                "gitcommit",
                "gitignore",
                "diff",

                -- Config, Data Serialization & Web
                "json",
                "jsonc",
                "json5",
                "yaml",
                "toml",
                "xml",
                "ini",
                "csv",
                "tsv",
                "html",
                "css",

                -- Documentation, Patterns & Editor Internals
                "markdown",
                "markdown_inline",
                "vim",
                "vimdoc",
                "regex",
                "query",
                "comment",
            },
        },
    },

    -- Allow Mason binaries into Neovim's runtime PATH, but keep auto-installs off
    {
        "mason-org/mason.nvim",
        opts = {
            ui = { border = "rounded" },
        },
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            automatic_installation = false,
        },
    },
}
