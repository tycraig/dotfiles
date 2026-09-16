#!/usr/bin/env bash
set -euo pipefail

echo "================================================="
echo "   AUTONOMOUS OFFLINE ENVIRONMENT DEPLOYMENT    "
echo "================================================="

ARCHIVE_FILE="${1:-$HOME/bundles/dev-bundle-latest.tar.gz}"

if [ ! -f "$ARCHIVE_FILE" ]; then
    if [ -f "./dev-bundle-latest.tar.gz" ]; then
        ARCHIVE_FILE="./dev-bundle-latest.tar.gz"
    else
        echo "[-] Error: Archive not found at $ARCHIVE_FILE"
        echo "    Usage: install.sh [path/to/dev-bundle.tar.gz]"
        exit 1
    fi
fi

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
BACKUP_DIR="$HOME/.dotfiles-backup/${TIMESTAMP}"

# --------------------------------------------------
# 1. Distro Detection & Host Dependencies
# --------------------------------------------------
echo "[1/7] Detecting platform and checking host packages..."
HAS_SUDO=false
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    HAS_SUDO=true
fi

if command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
    PKGS=(zsh tmux util-linux-user git curl tar xz unzip fontconfig)
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
    PKGS=(zsh tmux git curl tar xz-utils unzip fontconfig)
else
    PKG_MGR="unknown"
    PKGS=()
fi

MISSING=()
for p in zsh tmux git; do
    if ! command -v "$p" >/dev/null 2>&1; then
        MISSING+=("$p")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "[!] Missing core binaries: ${MISSING[*]}"
    if [ "$HAS_SUDO" = true ]; then
        if [ "$PKG_MGR" = "dnf" ]; then
            echo "[+] Installing packages via dnf..."
            sudo dnf install -y "${PKGS[@]}"
        elif [ "$PKG_MGR" = "apt" ]; then
            echo "[+] Installing packages via apt..."
            sudo apt-get update -qq && sudo apt-get install -y "${PKGS[@]}"
        fi
    else
        echo "[-] Warning: Non-root user. Please ensure ${MISSING[*]} are available."
    fi
fi

# --------------------------------------------------
# 2. Back Up Collisions & Unpack Bundle
# --------------------------------------------------
echo "[2/7] Clearing old caches and extracting archive..."
mkdir -p "$BACKUP_DIR"

# Clean wipe/backup of Neovim to prevent orphan plugin state
if [ -d "$HOME/.config/nvim" ] || [ -d "$HOME/.local/share/nvim" ]; then
    [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim-config"
    [ -d "$HOME/.local/share/nvim" ] && mv "$HOME/.local/share/nvim" "$BACKUP_DIR/nvim-share"
fi

tar -xzf "$ARCHIVE_FILE" -C "$HOME"

# --------------------------------------------------
# 3. Runtime Links & Permissions
# --------------------------------------------------
echo "[3/7] Re-linking runtimes and setting execution permissions..."
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

if [ -d "$HOME/.local/share/nvim/mason/bin" ]; then
    chmod +x "$HOME/.local/share/nvim/mason/bin/"* 2>/dev/null || true
fi

# Link Neovim from .local/opt
if [ -x "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
fi

# --------------------------------------------------
# 4. Dotfiles Checkout & Safe Collision Handling
# --------------------------------------------------
echo "[4/7] Checking out bare dotfiles repository..."
if [ -d "$HOME/.dotfiles" ]; then
    DOTFILES_GIT="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
    $DOTFILES_GIT config --local status.showUntrackedFiles no

    TRACKED_FILES=$($DOTFILES_GIT ls-tree -r --name-only HEAD)
    for file in $TRACKED_FILES; do
        TARGET_PATH="$HOME/$file"
        if [ -f "$TARGET_PATH" ] || [ -d "$TARGET_PATH" ]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            mv "$TARGET_PATH" "$BACKUP_DIR/$file"
        fi
    done
    $DOTFILES_GIT checkout main
fi

# --------------------------------------------------
# 5. Fonts, Manuals, and Terminfo
# --------------------------------------------------
echo "[5/7] Registering fonts, manpages, and terminfo..."
# Rebuild font cache if fonts directory exists
if [ -d "$HOME/.local/share/fonts" ] && command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true
fi

# Update man database
if [ -d "$HOME/.local/share/man" ] && command -v mandb >/dev/null 2>&1; then
    mandb -u 2>/dev/null || true
fi

# --------------------------------------------------
# 6. Shell Activation
# --------------------------------------------------
echo "[6/7] Configuring login shell..."
ZSH_BIN=$(command -v zsh || echo "$HOME/.local/bin/zsh")
if [ -x "$ZSH_BIN" ]; then
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        if chsh -s "$ZSH_BIN" "$USER" 2>/dev/null; then
            echo "[+] Login shell updated to Zsh via chsh."
        else
            echo "[!] Non-root user: injecting Zsh launcher guard into ~/.bashrc..."
            if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
                cat <<'BASH_EOF' >>"$HOME/.bashrc"

# Launch Zsh for interactive sessions if not already default
if [ -t 1 ] && [ -n "$PS1" ] && command -v zsh >/dev/null 2>&1; then
    exec zsh
fi
BASH_EOF
            fi
        fi
    fi
fi

# --------------------------------------------------
# 7. Smoke Test
# --------------------------------------------------
echo "[7/7] Running validation sanity suite..."
FAILURES=0

for cmd in rg fd fzf starship nvim; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  [✓] $cmd is available."
    else
        echo "  [✗] $cmd is NOT functional."
        FAILURES=$((FAILURES + 1))
    fi
done

# Headless Neovim test
if nvim --headless "+qa" >/dev/null 2>&1; then
    echo "  [✓] Neovim headless init passed."
else
    echo "  [✗] Neovim failed startup."
    FAILURES=$((FAILURES + 1))
fi

# Clean up empty backup directory if nothing was backed up
if [ -d "$BACKUP_DIR" ] && [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    rm -rf "$BACKUP_DIR"
fi

echo "================================================="
if [ $FAILURES -eq 0 ]; then
    echo "  DEPLOYMENT COMPLETE: PARITY VERIFIED          "
else
    echo "  DEPLOYMENT FINISHED WITH $FAILURES ISSUES     "
fi
echo "================================================="
echo "Reload your session: exec zsh"
