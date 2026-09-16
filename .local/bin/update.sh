#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-plugins}"
FORCE=false
if [[ "${1:-}" == "--force" || "${2:-}" == "--force" || "${1:-}" == "-f" || "${2:-}" == "-f" ]]; then
    FORCE=true
fi

BIN_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
MAN_DIR="$HOME/.local/share/man/man1"
ZSH_COMP_DIR="$HOME/.local/share/zsh/site-functions"
FZF_SHARE="$HOME/.local/share/fzf"

mkdir -p "$BIN_DIR" "$OPT_DIR" "$MAN_DIR" "$ZSH_COMP_DIR" "$FZF_SHARE"

CHANGES_MADE=false

# Helper: Resolve latest release tag without REST API limits
get_latest_github_tag() {
    local repo="$1"
    curl -sIL -o /dev/null -w '%{url_effective}' "https://github.com/${repo}/releases/latest" |
        sed -E 's|.*/tag/v?||' | tr -d '\r\n'
}

# ==================================================
# 1. CLI Tools (ripgrep, fd, fzf, starship, lazygit, zoxide)
# ==================================================
update_cli_tools() {
    echo "─── Checking CLI Utilities ───"

    # Starship
    local current_starship latest_starship
    current_starship=$("$BIN_DIR/starship" --version 2>/dev/null | head -n1 | awk '{print $2}' || echo "none")
    latest_starship=$(get_latest_github_tag "starship/starship")
    if [[ "$current_starship" != "$latest_starship" || "$FORCE" == true ]]; then
        echo "  [+] Upgrading Starship ($current_starship -> $latest_starship)..."
        curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$BIN_DIR" -y >/dev/null
        CHANGES_MADE=true
    else
        echo "  [=] Starship is current ($current_starship)."
    fi

    # Ripgrep
    local current_rg latest_rg
    current_rg=$("$BIN_DIR/rg" --version 2>/dev/null | head -n1 | awk '{print $2}' || echo "none")
    latest_rg=$(get_latest_github_tag "BurntSushi/ripgrep")
    if [[ "$current_rg" != "$latest_rg" || "$FORCE" == true ]]; then
        echo "  [+] Upgrading ripgrep ($current_rg -> $latest_rg)..."
        TMP_RG=$(mktemp -d)
        curl -sL "https://github.com/BurntSushi/ripgrep/releases/download/${latest_rg}/ripgrep-${latest_rg}-x86_64-unknown-linux-musl.tar.gz" \
            -o "$TMP_RG/rg.tar.gz"
        tar -xzf "$TMP_RG/rg.tar.gz" -C "$TMP_RG"
        RG_SRC=$(find "$TMP_RG" -type d -name "ripgrep-*" | head -n 1)
        install -m 755 "$RG_SRC/rg" "$BIN_DIR/rg"
        [ -f "$RG_SRC/doc/rg.1" ] && install -m 644 "$RG_SRC/doc/rg.1" "$MAN_DIR/rg.1"
        [ -f "$RG_SRC/complete/_rg" ] && install -m 644 "$RG_SRC/complete/_rg" "$ZSH_COMP_DIR/_rg"
        rm -rf "$TMP_RG"
        CHANGES_MADE=true
    else
        echo "  [=] ripgrep is current ($current_rg)."
    fi

    # fd
    local current_fd latest_fd
    current_fd=$("$BIN_DIR/fd" --version 2>/dev/null | head -n1 | awk '{print $2}' || echo "none")
    latest_fd=$(get_latest_github_tag "sharkdp/fd")
    if [[ "$current_fd" != "$latest_fd" || "$FORCE" == true ]]; then
        echo "  [+] Upgrading fd ($current_fd -> $latest_fd)..."
        TMP_FD=$(mktemp -d)
        curl -sL "https://github.com/sharkdp/fd/releases/download/v${latest_fd}/fd-v${latest_fd}-x86_64-unknown-linux-musl.tar.gz" \
            -o "$TMP_FD/fd.tar.gz"
        tar -xzf "$TMP_FD/fd.tar.gz" -C "$TMP_FD"
        FD_SRC=$(find "$TMP_FD" -type d -name "fd-*" | head -n 1)
        install -m 755 "$FD_SRC/fd" "$BIN_DIR/fd"
        [ -f "$FD_SRC/fd.1" ] && install -m 644 "$FD_SRC/fd.1" "$MAN_DIR/fd.1"
        [ -f "$FD_SRC/autocomplete/_fd" ] && install -m 644 "$FD_SRC/autocomplete/_fd" "$ZSH_COMP_DIR/_fd"
        rm -rf "$TMP_FD"
        CHANGES_MADE=true
    else
        echo "  [=] fd is current ($current_fd)."
    fi

    # fzf
    local current_fzf latest_fzf
    current_fzf=$("$BIN_DIR/fzf" --version 2>/dev/null | awk '{print $1}' || echo "none")
    latest_fzf=$(get_latest_github_tag "junegunn/fzf")
    if [[ "$current_fzf" != "$latest_fzf" || "$FORCE" == true ]]; then
        echo "  [+] Upgrading fzf ($current_fzf -> $latest_fzf)..."
        TMP_FZF=$(mktemp -d)
        curl -sL "https://github.com/junegunn/fzf/releases/download/v${latest_fzf}/fzf-${latest_fzf}-linux_amd64.tar.gz" \
            -o "$TMP_FZF/fzf.tar.gz"
        tar -xzf "$TMP_FZF/fzf.tar.gz" -C "$TMP_FZF"
        install -m 755 "$TMP_FZF/fzf" "$BIN_DIR/fzf"
        curl -sLo "$BIN_DIR/fzf-tmux" https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux
        chmod +x "$BIN_DIR/fzf-tmux"
        curl -sLo "$MAN_DIR/fzf.1" https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1
        curl -sLo "$MAN_DIR/fzf-tmux.1" https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf-tmux.1
        curl -sLo "$FZF_SHARE/completion.zsh" https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh
        curl -sLo "$FZF_SHARE/key-bindings.zsh" https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh
        rm -rf "$TMP_FZF"
        CHANGES_MADE=true
    else
        echo "  [=] fzf is current ($current_fzf)."
    fi

    # Lazygit
    local current_lazygit latest_lazygit
    current_lazygit=$("$BIN_DIR/lazygit" --version 2>/dev/null | grep -o 'version=[^,]*' | head -n1 | cut -d= -f2 || echo "none")
    latest_lazygit=$(get_latest_github_tag "jesseduffield/lazygit")
    if [[ "$current_lazygit" != "$latest_lazygit" || "$FORCE" == true ]]; then
        echo "  [+] Upgrading lazygit ($current_lazygit -> $latest_lazygit)..."
        TMP_LG=$(mktemp -d)
        curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${latest_lazygit}/lazygit_${latest_lazygit}_Linux_x86_64.tar.gz" \
            -o "$TMP_LG/lazygit.tar.gz"
        tar -xzf "$TMP_LG/lazygit.tar.gz" -C "$TMP_LG"
        install -m 755 "$TMP_LG/lazygit" "$BIN_DIR/lazygit"
        rm -rf "$TMP_LG"
        CHANGES_MADE=true
    else
        echo "  [=] lazygit is current ($current_lazygit)."
    fi

    # Zoxide
    local current_zoxide latest_zoxide
    current_zoxide=$("$BIN_DIR/zoxide" --version 2>/dev/null | head -n1 | awk '{print $2}' || echo "none")
    latest_zoxide=$(get_latest_github_tag "ajeetdsouza/zoxide")
    if [[ "$current_zoxide" != "$latest_zoxide" || "$FORCE" == true ]]; then
        echo "  [+] Upgrading zoxide ($current_zoxide -> $latest_zoxide)..."
        TMP_ZO=$(mktemp -d)
        curl -sL "https://github.com/ajeetdsouza/zoxide/releases/download/v${latest_zoxide}/zoxide-${latest_zoxide}-x86_64-unknown-linux-musl.tar.gz" \
            -o "$TMP_ZO/zoxide.tar.gz"
        tar -xzf "$TMP_ZO/zoxide.tar.gz" -C "$TMP_ZO"
        install -m 755 "$TMP_ZO/zoxide" "$BIN_DIR/zoxide"
        curl -sLo "$ZSH_COMP_DIR/_zoxide" "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/contrib/completions/_zoxide"
        chmod 644 "$ZSH_COMP_DIR/_zoxide"
        for manpage in zoxide.1 zoxide-add.1 zoxide-import.1 zoxide-init.1 zoxide-query.1 zoxide-remove.1; do
            curl -sLo "$MAN_DIR/$manpage" "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/man/man1/$manpage"
            chmod 644 "$MAN_DIR/$manpage"
        done
        rm -rf "$TMP_ZO"
        CHANGES_MADE=true
    else
        echo "  [=] zoxide is current ($current_zoxide)."
    fi

    command -v mandb >/dev/null 2>&1 && mandb -u >/dev/null 2>&1 || true
}

# ==================================================
# 2. Neovim Core Binary
# ==================================================
update_nvim_core() {
    echo "─── Checking Neovim Core Binary ───"
    local current_nvim latest_nvim
    current_nvim=$("$BIN_DIR/nvim" --version 2>/dev/null | head -n1 | awk '{print $2}' | sed 's/^v//' || echo "none")
    latest_nvim=$(get_latest_github_tag "neovim/neovim")

    if [[ "$current_nvim" != "$latest_nvim" || "$FORCE" == true ]]; then
        echo "  [+] Upgrading Neovim runtime ($current_nvim -> $latest_nvim)..."
        TMP_NVIM=$(mktemp -d)
        curl -sLo "$TMP_NVIM/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        rm -rf "$OPT_DIR/nvim-linux-x86_64"
        tar -C "$OPT_DIR" -xzf "$TMP_NVIM/nvim.tar.gz"
        rm -rf "$TMP_NVIM"
        ln -sf "$OPT_DIR/nvim-linux-x86_64/bin/nvim" "$BIN_DIR/nvim"
        CHANGES_MADE=true
    else
        echo "  [=] Neovim is current ($current_nvim)."
    fi
}

# ==================================================
# 3. WezTerm Terminfo
# ==================================================
update_terminfo() {
    echo "─── Checking WezTerm Terminfo ───"
    TMP_TI=$(mktemp)
    curl -sLo "$TMP_TI" https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo
    mkdir -p "$HOME/.local/share/terminfo" "$HOME/.terminfo"

    if ! cmp -s "$TMP_TI" "$HOME/.local/share/terminfo/wezterm.terminfo" 2>/dev/null; then
        echo "  [+] Terminfo change detected. Recompiling..."
        mv "$TMP_TI" "$HOME/.local/share/terminfo/wezterm.terminfo"
        tic -x -o "$HOME/.terminfo" "$HOME/.local/share/terminfo/wezterm.terminfo"
        CHANGES_MADE=true
    else
        echo "  [=] WezTerm terminfo is up to date."
        rm -f "$TMP_TI"
    fi
}

# ==================================================
# 4. Routine Plugins & Neovim State
# ==================================================
update_plugins() {
    echo "─── Checking Zsh Plugins ───"
    ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
    if [ -d "$ZSH_PLUGIN_DIR" ]; then
        for plugin in "$ZSH_PLUGIN_DIR"/*; do
            if [ -d "$plugin/.git" ]; then
                git -C "$plugin" fetch -q origin
                LOCAL=$(git -C "$plugin" rev-parse @)
                REMOTE=$(git -C "$plugin" rev-parse '@{u}' 2>/dev/null || echo "$LOCAL")
                if [ "$LOCAL" != "$REMOTE" ]; then
                    echo "  [+] Updating $(basename "$plugin")..."
                    git -C "$plugin" pull --ff-only
                    CHANGES_MADE=true
                else
                    echo "  [=] $(basename "$plugin") is up to date."
                fi
            fi
        done
    fi

    echo "─── Updating Neovim Packages ───"
    local lockfile="$HOME/.config/nvim/lazy-lock.json"
    local old_hash="" new_hash=""
    [ -f "$lockfile" ] && old_hash=$(sha256sum "$lockfile" | awk '{print $1}')

    # 1. Update plugins headlessly via Lazy
    echo "  -> Running Lazy sync..."
    nvim --headless "+Lazy! sync" +qa

    # 2. Load Treesitter into memory, then synchronously recompile grammars
    echo "  -> Updating Treesitter parsers..."
    # 2. Load Treesitter and run synchronous update without the trailing ()
    echo "  -> Updating Treesitter parsers..."
    nvim --headless \
        -c "Lazy load nvim-treesitter" \
        -c "lua require('nvim-treesitter.install').update({ with_sync = true })" \
        +qa

    # 3. Load Mason into memory, then refresh package registries
    echo "  -> Updating Mason registries..."
    nvim --headless \
        -c "Lazy load mason.nvim" \
        -c "lua local done = false; require('mason-registry').refresh(function() done = true end); vim.wait(15000, function() return done end)" \
        +qa

    [ -f "$lockfile" ] && new_hash=$(sha256sum "$lockfile" | awk '{print $1}')
    if [ "$old_hash" != "$new_hash" ]; then
        echo "  [+] Neovim plugins or lockfile were updated."
        CHANGES_MADE=true
    else
        echo "  [=] Neovim lockfile unchanged."
    fi
}

# ==================================================
# Execution Routing
# ==================================================
case "$MODE" in
--tools | -t)
    update_cli_tools
    ;;
--nvim | -n)
    update_nvim_core
    ;;
--terminfo)
    update_terminfo
    ;;
--all | -a)
    update_cli_tools
    update_nvim_core
    update_terminfo
    update_plugins
    ;;
plugins | *)
    update_plugins
    ;;
esac

# ==================================================
# Validation Gate & Smart Rebundling
# ==================================================
echo "─── Validation Gate ───"
if ! nvim --headless "+qa" >/dev/null 2>&1; then
    echo "[-] ERROR: Neovim failed headless check. Fix errors before bundling."
    exit 1
fi
echo "  [✓] Neovim headless init passed."

if [ "$CHANGES_MADE" = true ] || [ "$FORCE" = true ]; then
    if [ -d "$HOME/.dotfiles" ]; then
        /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" add "$HOME/.config/nvim/lazy-lock.json" 2>/dev/null || true
        /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" commit -m "Automated update: bump lockfile and dependencies" 2>/dev/null || true
    fi

    echo "==> Changes confirmed. Generating fresh bundle archive..."
    "$BIN_DIR/bundle.sh"
else
    echo "==> All components are already at latest versions."
    echo "    Skipping tarball generation (pass --force to override)."
fi
