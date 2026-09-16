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

log_version() {
    local name="$1"
    local cmd="$2"
    echo "[$name]" >>"$MANIFEST_FILE"
    if command -v "${cmd%% *}" >/dev/null 2>&1; then
        eval "$cmd" 2>&1 | head -n 3 >>"$MANIFEST_FILE"
    else
        echo "NOT FOUND" >>"$MANIFEST_FILE"
    fi
    echo "" >>"$MANIFEST_FILE"
}

# Core CLI Toolchain
log_version "Zsh" "zsh --version"
log_version "Tmux" "tmux -V"
log_version "Starship" "starship --version"
log_version "Neovim" "nvim --version"
log_version "Ripgrep (rg)" "rg --version"
log_version "fd-find" "fd --version"
log_version "fzf" "fzf --version"
log_version "Git" "git --version"
log_version "Lazygit" "lazygit --version"
log_version "Zoxide" "zoxide --version"

# Static Formatters & Linters
log_version "StyLua" "stylua --version"
log_version "shfmt" "shfmt --version"
log_version "Ruff" "ruff --version"

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
