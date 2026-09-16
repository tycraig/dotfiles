#!/usr/bin/env bash
set -euo pipefail

echo "================================================="
echo "   AUTONOMOUS OFFLINE ENVIRONMENT DEPLOYMENT    "
echo "================================================="

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
BACKUP_DIR="$HOME/.dotfiles-backup/${TIMESTAMP}"
DOTFILES_GIT="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# --------------------------------------------------
# 1. Distro Detection & Host Dependencies
# --------------------------------------------------
echo "[1/6] Checking host dependencies..."
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
    echo "[!] Missing core packages: ${MISSING[*]}"
    if [ "$HAS_SUDO" = true ]; then
        if [ "$PKG_MGR" = "dnf" ]; then
            sudo dnf install -y "${PKGS[@]}"
        elif [ "$PKG_MGR" = "apt" ]; then
            sudo apt-get update -qq && sudo apt-get install -y "${PKGS[@]}"
        fi
    else
        echo "[-] Notice: Non-root user. Assuming host packages are pre-installed."
    fi
fi

# --------------------------------------------------
# 2. Extract Archive (If Provided)
# --------------------------------------------------
ARCHIVE_FILE="${1:-}"
if [ -n "$ARCHIVE_FILE" ] && [ -f "$ARCHIVE_FILE" ]; then
    echo "[2/6] Extracting archive payload from $ARCHIVE_FILE..."
    tar -xzf "$ARCHIVE_FILE" -C "$HOME"
else
    echo "[2/6] Archive already extracted. Proceeding with configuration..."
fi

# --------------------------------------------------
# 3. Force Checkout Tracked Dotfiles
# --------------------------------------------------
echo "[3/6] Populating dotfiles into $HOME..."
if [ -d "$HOME/.dotfiles" ]; then
    $DOTFILES_GIT config --local status.showUntrackedFiles no

    # Back up existing files that collide with repository files
    mkdir -p "$BACKUP_DIR"
    TRACKED_FILES=$($DOTFILES_GIT ls-tree -r --name-only HEAD)
    for file in $TRACKED_FILES; do
        TARGET_PATH="$HOME/$file"
        if [ -e "$TARGET_PATH" ] && [ ! -L "$TARGET_PATH" ]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            cp -a "$TARGET_PATH" "$BACKUP_DIR/$file"
        fi
    done

    # Force write all files from HEAD into $HOME
    $DOTFILES_GIT checkout -f main
fi

# --------------------------------------------------
# 4. Runtime Links & Permissions
# --------------------------------------------------
echo "[4/6] Setting executable permissions and symlinks..."
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

if [ -d "$HOME/.local/share/nvim/mason/bin" ]; then
    chmod +x "$HOME/.local/share/nvim/mason/bin/"* 2>/dev/null || true
fi

# Link Neovim binary
if [ -x "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
fi

# --------------------------------------------------
# 5. Fonts, Manuals, and Terminfo
# --------------------------------------------------
echo "[5/6] Registering fonts, terminfo, and manpages..."
if [ -d "$HOME/.local/share/fonts" ] && command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true
fi

if [ -d "$HOME/.local/share/man" ] && command -v mandb >/dev/null 2>&1; then
    mandb -u 2>/dev/null || true
fi

# --------------------------------------------------
# 6. Shell Activation & Health Check
# --------------------------------------------------
echo "[6/6] Configuring login shell and verifying health..."
ZSH_BIN=$(command -v zsh || echo "$HOME/.local/bin/zsh")
if [ -x "$ZSH_BIN" ]; then
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        if chsh -s "$ZSH_BIN" "$USER" 2>/dev/null; then
            echo "[+] Login shell updated to Zsh."
        else
            echo "[!] Non-root user: injecting Zsh launcher guard into ~/.bashrc..."
            if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
                cat << 'BASH_EOF' >> "$HOME/.bashrc"

# Launch Zsh for interactive sessions if not default
if [ -t 1 ] && [ -n "$PS1" ] && command -v zsh >/dev/null 2>&1; then
    exec zsh
fi
BASH_EOF
            fi
        fi
    fi
fi

# Headless sanity tests
FAILURES=0
for cmd in rg fd fzf starship nvim; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  [✓] $cmd is available."
    else
        echo "  [✗] $cmd is NOT functional."
        FAILURES=$((FAILURES + 1))
    fi
done

if nvim --headless "+qa" >/dev/null 2>&1; then
    echo "  [✓] Neovim headless init passed."
else
    echo "  [✗] Neovim failed startup."
    FAILURES=$((FAILURES + 1))
fi

# Clean up empty backup directory
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
echo "Reload session: exec zsh"
