#!/usr/bin/env bash
set -euo pipefail

AUTO_CONFIRM=false
if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" || "${1:-}" == "--force" || "${1:-}" == "-f" ]]; then
    AUTO_CONFIRM=true
fi

echo "================================================="
echo "   OFFLINE ENVIRONMENT UNINSTALLER & RESET      "
echo "================================================="
echo "This script will remove the offline development environment"
echo "from your user profile ($HOME), including:"
echo "  - Tracked dotfiles and bare Git repository (~/.dotfiles)"
echo "  - Whitelisted standalone binaries in ~/.local/bin"
echo "  - Extracted runtimes (~/.local/opt, Mason, Lazy, Fonts, GEF)"
echo "  - Environment man pages, completions, and terminfo"
echo "  - Injected Zsh launcher guard in ~/.bashrc"
echo "It will also restore your latest backup from ~/.dotfiles-backup if present."
echo "================================================="

if [ "$AUTO_CONFIRM" = false ]; then
    read -rp "Are you sure you want to proceed with uninstallation? [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            echo "[-] Uninstallation aborted by user."
            exit 0
            ;;
    esac
fi

echo "[1/7] Removing tracked repository dotfiles..."
if [ -d "$HOME/.dotfiles" ]; then
    DOTFILES_GIT="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
    TRACKED_FILES=$($DOTFILES_GIT ls-tree -r --name-only HEAD 2>/dev/null || true)
    for file in $TRACKED_FILES; do
        TARGET_PATH="$HOME/$file"
        if [ -e "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
            rm -rf "$TARGET_PATH"
        fi
    done
    rm -rf "$HOME/.dotfiles"
    echo "  [✓] Removed tracked files and bare repository ~/.dotfiles."
else
    echo "  [-] ~/.dotfiles repository not found. Skipping tracked files removal."
fi

echo "[2/7] Restoring original dotfiles from backup..."
if [ -d "$HOME/.dotfiles-backup" ]; then
    LATEST_BACKUP=$(ls -td "$HOME/.dotfiles-backup"/* 2>/dev/null | head -n 1 || true)
    if [ -n "$LATEST_BACKUP" ] && [ -d "$LATEST_BACKUP" ]; then
        echo "  [+] Restoring files from $LATEST_BACKUP..."
        cp -a "$LATEST_BACKUP"/. "$HOME/"
        echo "  [✓] Original dotfiles restored."
    else
        echo "  [-] No backup directories found in ~/.dotfiles-backup."
    fi
else
    echo "  [-] No ~/.dotfiles-backup directory found."
fi

echo "[3/7] Cleaning ~/.bashrc launcher injection..."
if [ -f "$HOME/.bashrc" ]; then
    if grep -q "Launch Zsh for interactive sessions if not default" "$HOME/.bashrc" 2>/dev/null; then
        sed -i '/# Launch Zsh for interactive sessions if not default/,/fi/d' "$HOME/.bashrc"
        echo "  [✓] Removed Zsh launcher block from ~/.bashrc."
    fi
fi

echo "[4/7] Removing standalone environment binaries..."
BIN_LIST=(
    "bundle.sh"
    "fd"
    "fzf"
    "fzf-tmux"
    "generate_manifest.sh"
    "install.sh"
    "lazygit"
    "nvim"
    "rg"
    "starship"
    "update.sh"
    "zoxide"
    "uninstall.sh"
    "bat"
    "delta"
    "tldr"
    "tealdeer"
)

for bin in "${BIN_LIST[@]}"; do
    TARGET_BIN="$HOME/.local/bin/$bin"
    if [ -e "$TARGET_BIN" ] || [ -L "$TARGET_BIN" ]; then
        rm -f "$TARGET_BIN"
    fi
done
echo "  [✓] Removed environment binaries from ~/.local/bin."

echo "[5/7] Removing application runtimes, plugins, and caches..."
rm -rf "$HOME/.local/opt/nvim-linux-x86_64"
rm -f "$HOME/.local/env-manifest.txt"
rm -rf "$HOME/.local/share/nvim"
rm -rf "$HOME/.local/share/zsh"
rm -rf "$HOME/.local/share/fzf"
rm -rf "$HOME/.local/share/fonts/JetBrainsMono"
rm -rf "$HOME/.local/share/gef"
rm -rf "$HOME/.local/share/terminfo"
rm -rf "$HOME/.terminfo"
rm -rf "$HOME/.cache/tealdeer"
rm -rf "$HOME/.config/dotfiles"
rm -rf "$HOME/.config/nvim"
rm -rf "$HOME/.config/wezterm"
rm -rf "$HOME/.config/lazygit"
rm -f "$HOME/.config/starship.toml"

echo "[6/7] Removing manual pages and rebuilding system caches..."
MAN1_FILES=(
    "rg.1"
    "fd.1"
    "fzf.1"
    "fzf-tmux.1"
    "zoxide.1"
    "zoxide-add.1"
    "zoxide-import.1"
    "zoxide-init.1"
    "zoxide-query.1"
    "zoxide-remove.1"
    "bat.1"
    "delta.1"
    "tldr.1"
)
for man in "${MAN1_FILES[@]}"; do
    rm -f "$HOME/.local/share/man/man1/$man"
done

if [ -d "$HOME/.local/share/fonts" ] && command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true
fi

if command -v mandb >/dev/null 2>&1; then
    mandb -u 2>/dev/null || true
fi

echo "[7/7] Pruning empty directory structures..."
rmdir "$HOME/.local/share/man/man1" 2>/dev/null || true
rmdir "$HOME/.local/share/man" 2>/dev/null || true
rmdir "$HOME/.local/share/fonts" 2>/dev/null || true
rmdir "$HOME/.local/share" 2>/dev/null || true
rmdir "$HOME/.local/opt" 2>/dev/null || true
rmdir "$HOME/.local/bin" 2>/dev/null || true
rmdir "$HOME/.local" 2>/dev/null || true
rmdir "$HOME/.config" 2>/dev/null || true

echo "================================================="
echo "  UNINSTALLATION COMPLETE: BASELINE RESTORED     "
echo "================================================="
echo "If your login shell was set to zsh, restore bash with: chsh -s /bin/bash"
echo "To reset your active terminal session: exec bash"
