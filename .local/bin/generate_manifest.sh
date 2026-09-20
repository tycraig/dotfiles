#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/share/nvim/mason/bin:$HOME/.local/bin:$PATH"

MANIFEST_FILE="${HOME}/.local/env-manifest.txt"
mkdir -p "$(dirname "$MANIFEST_FILE")"

echo "=== DEV ENVIRONMENT MANIFEST ===" >"$MANIFEST_FILE"
echo "Generated on: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" >>"$MANIFEST_FILE"
echo "Hostname: $(hostname)" >>"$MANIFEST_FILE"
echo "Architecture: $(uname -m)" >>"$MANIFEST_FILE"
echo "=================================" >>"$MANIFEST_FILE"
echo "" >>"$MANIFEST_FILE"

log_tool() {
    local name="$1"
    local cmd="$2"
    local bin="${cmd%% *}"
    echo "[$name]" >>"$MANIFEST_FILE"
    if command -v "$bin" >/dev/null 2>&1; then
        local bin_path
        bin_path=$(command -v "$bin")
        local real_path
        real_path=$(readlink -f "$bin_path" 2>/dev/null || echo "$bin_path")
        if [[ "$real_path" == /usr/* || "$real_path" == /bin/* ]]; then
            echo "Source: System Package ($bin_path -> $real_path)" >>"$MANIFEST_FILE"
        elif [[ "$real_path" == "$HOME"/.local/* ]]; then
            echo "Source: Bundled Binary ($bin_path)" >>"$MANIFEST_FILE"
        else
            echo "Source: Custom/Host ($bin_path)" >>"$MANIFEST_FILE"
        fi
        eval "$cmd" 2>&1 | head -n 3 >>"$MANIFEST_FILE"
    else
        echo "NOT FOUND" >>"$MANIFEST_FILE"
    fi
    echo "" >>"$MANIFEST_FILE"
}

# Core CLI Toolchain
log_tool "Zsh" "zsh --version"
log_tool "Tmux" "tmux -V"
log_tool "Starship" "starship --version"
log_tool "Neovim" "nvim --version"
log_tool "Ripgrep (rg)" "rg --version"
log_tool "fd-find" "fd --version"
log_tool "fzf" "fzf --version"
log_tool "Git" "git --version"
log_tool "Lazygit" "lazygit --version"
log_tool "Zoxide" "zoxide --version"
log_tool "bat" "bat --version"
log_tool "delta" "delta --version"
log_tool "tealdeer (tldr)" "tldr --version"
log_tool "eza" "eza --version"

# Static Formatters & Linters
log_tool "StyLua" "stylua --version"
log_tool "shfmt" "shfmt --version"
log_tool "Ruff" "ruff --version"

# Debugging & Binary Analysis
echo "[GEF]" >>"$MANIFEST_FILE"
GEF_SCRIPT="${HOME}/.local/share/gef/gef.py"
if [ -f "$GEF_SCRIPT" ]; then
    echo "Installed (${GEF_SCRIPT})" >>"$MANIFEST_FILE"
else
    echo "NOT FOUND" >>"$MANIFEST_FILE"
fi
echo "" >>"$MANIFEST_FILE"

# Mason Toolchain Binaries
MASON_BIN="${HOME}/.local/share/nvim/mason/bin"
if [ -d "$MASON_BIN" ]; then
    echo "=== MASON INSTALLED BINARIES ===" >>"$MANIFEST_FILE"
    ls -1 "$MASON_BIN" >>"$MANIFEST_FILE"
    echo "" >>"$MANIFEST_FILE"
fi

# Treesitter Compiled Parsers Count
TS_PARSER_DIR="${HOME}/.local/share/nvim/lazy/nvim-treesitter/parser"
if [ -d "$TS_PARSER_DIR" ]; then
    echo "=== TREESITTER COMPILED PARSERS ===" >>"$MANIFEST_FILE"
    echo "Total compiled parsers: $(ls -1 "$TS_PARSER_DIR"/*.so 2>/dev/null | wc -l)" >>"$MANIFEST_FILE"
    echo "" >>"$MANIFEST_FILE"
fi

echo "Manifest successfully written to: $MANIFEST_FILE"
