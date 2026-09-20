#!/usr/bin/env bash
set -euo pipefail

echo "================================================="
echo "   AUTONOMOUS OFFLINE ENVIRONMENT DEPLOYMENT    "
echo "================================================="

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
BACKUP_DIR="$HOME/.dotfiles-backup/${TIMESTAMP}"
DOTFILES_GIT="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Ensure ~/.local/bin is present in PATH for current script execution
export PATH="$HOME/.local/bin:$PATH"

# --------------------------------------------------
# 1. Distro Detection & Host Dependencies
# --------------------------------------------------
echo "[1/5] Checking host dependencies..."
if [ "$(uname -m)" != "x86_64" ]; then
    echo "[-] ERROR: This offline environment bundle is built for x86_64 hosts only." >&2
    exit 1
fi

HAS_SUDO=false
if command -v sudo >/dev/null 2>&1; then
    if sudo -n true 2>/dev/null; then
        HAS_SUDO=true
    elif [ -t 0 ] && [ -t 1 ]; then
        echo -n "[?] Prompt for sudo credentials to install host packages? [y/N] "
        if read -r -t 3 answer 2>/dev/null && [[ "$answer" =~ ^[Yy]$ ]]; then
            if sudo -v 2>/dev/null; then
                HAS_SUDO=true
            fi
        fi
    fi
fi

if command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
    PKGS=(ripgrep fd-find bat fzf eza zsh tmux util-linux-user git curl tar zstd xz unzip fontconfig)
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
    PKGS=(ripgrep fd-find bat fzf eza zsh tmux git curl tar zstd xz-utils unzip fontconfig)
else
    PKG_MGR="unknown"
    PKGS=()
fi

if [ "$HAS_SUDO" = true ] && [ "$PKG_MGR" != "unknown" ]; then
    echo "[+] Attempting host package installation via ${PKG_MGR}..."
    if [ "$PKG_MGR" = "dnf" ]; then
        if ! sudo dnf install -y --setopt=install_weak_deps=False "${PKGS[@]}" 2>/dev/null; then
            echo "[-] Notice: DNF installation encountered errors or offline mirrors. Proceeding with fallback."
        fi
    elif [ "$PKG_MGR" = "apt" ]; then
        if ! (sudo apt-get update -qq 2>/dev/null && sudo apt-get install -y "${PKGS[@]}" 2>/dev/null); then
            echo "[-] Notice: APT installation encountered errors or offline mirrors. Proceeding with fallback."
        fi
    fi
else
    echo "[-] Notice: Non-root user or offline mirrors. Skipping host package installation."
fi

# Optional fallback: extract archive if explicitly provided as an argument
if [ -n "${1:-}" ] && [ -f "${1:-}" ]; then
    echo "[+] Archive argument detected. Unpacking ${1} into $HOME..."
    if [[ "${1}" == *.tar.zst ]]; then
        tar -I zstd -xf "${1}" -C "$HOME"
    else
        tar -xzf "${1}" -C "$HOME"
    fi
fi

# --------------------------------------------------
# 2. Force Checkout Tracked Dotfiles
# --------------------------------------------------
echo "[2/5] Populating dotfiles into $HOME..."
if [ -d "$HOME/.dotfiles" ]; then
    $DOTFILES_GIT config --local status.showUntrackedFiles no

    # Auto-migrate pre-existing ~/.gitconfig to ~/.gitconfig.local if not already configured
    if [ -s "$HOME/.gitconfig" ] && [ ! -f "$HOME/.gitconfig.local" ]; then
        if ! $DOTFILES_GIT diff --quiet HEAD -- "$HOME/.gitconfig" 2>/dev/null; then
            echo "[+] Pre-existing ~/.gitconfig detected. Migrating to ~/.gitconfig.local..."
            cp -a "$HOME/.gitconfig" "$HOME/.gitconfig.local"
            # Remove recursive include directive if present
            git config -f "$HOME/.gitconfig.local" --unset-all include.path "^~/.gitconfig.local$" 2>/dev/null || true
            echo "  [✓] Host Git settings retained in ~/.gitconfig.local."
        fi
    fi

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
# 3. Tool Resolution, Name Normalization & Runtime Permissions
# --------------------------------------------------
echo "[3/5] Resolving toolchain binaries and normalizing names..."
mkdir -p "$HOME/.local/bin"

find_system_bin() {
    local name="$1"
    for dir in /usr/bin /usr/local/bin /bin; do
        if [ -x "$dir/$name" ]; then
            echo "$dir/$name"
            return 0
        fi
    done
    return 1
}

TRACKED_TOOLS=(rg fd bat fzf eza starship lazygit zoxide delta tldr)
STAGING_BIN_DIR="$HOME/.local/share/dev-bundle/bin"

for tool in "${TRACKED_TOOLS[@]}"; do
    case "$tool" in
        fd)
            if host_fdfind=$(find_system_bin fdfind); then
                ln -sf "$host_fdfind" "$HOME/.local/bin/fd"
                echo "  [✓] fd normalized -> $host_fdfind"
            elif host_fd=$(find_system_bin fd); then
                rm -f "$HOME/.local/bin/fd"
                echo "  [✓] fd resolved to system ($host_fd)"
            elif [ -f "$STAGING_BIN_DIR/fd" ]; then
                cp -a "$STAGING_BIN_DIR/fd" "$HOME/.local/bin/fd"
                chmod +x "$HOME/.local/bin/fd"
                echo "  [✓] fd deployed from staging cache"
            fi
            ;;
        bat)
            if host_batcat=$(find_system_bin batcat); then
                ln -sf "$host_batcat" "$HOME/.local/bin/bat"
                echo "  [✓] bat normalized -> $host_batcat"
            elif host_bat=$(find_system_bin bat); then
                rm -f "$HOME/.local/bin/bat"
                echo "  [✓] bat resolved to system ($host_bat)"
            elif [ -f "$STAGING_BIN_DIR/bat" ]; then
                cp -a "$STAGING_BIN_DIR/bat" "$HOME/.local/bin/bat"
                chmod +x "$HOME/.local/bin/bat"
                echo "  [✓] bat deployed from staging cache"
            fi
            ;;
        *)
            if host_bin=$(find_system_bin "$tool"); then
                rm -f "$HOME/.local/bin/$tool"
                echo "  [✓] $tool resolved to system ($host_bin)"
            elif [ -f "$STAGING_BIN_DIR/$tool" ]; then
                cp -a "$STAGING_BIN_DIR/$tool" "$HOME/.local/bin/$tool"
                chmod +x "$HOME/.local/bin/$tool"
                echo "  [✓] $tool deployed from staging cache"
            fi
            ;;
    esac
done

# Ensure companion tools are linked / deployed
if [ -f "$HOME/.local/bin/tldr" ] || find_system_bin tldr >/dev/null 2>&1; then
    ln -sf tldr "$HOME/.local/bin/tealdeer"
fi

if ! find_system_bin fzf-tmux >/dev/null 2>&1; then
    if [ -f "$STAGING_BIN_DIR/fzf-tmux" ]; then
        cp -a "$STAGING_BIN_DIR/fzf-tmux" "$HOME/.local/bin/fzf-tmux"
        chmod +x "$HOME/.local/bin/fzf-tmux"
    fi
else
    rm -f "$HOME/.local/bin/fzf-tmux"
fi

# Link Neovim binary
if [ -x "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" ]; then
    ln -sf "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
fi

chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

if [ -d "$HOME/.local/share/nvim/mason/bin" ]; then
    chmod +x "$HOME/.local/share/nvim/mason/bin/"* 2>/dev/null || true
fi

# --------------------------------------------------
# 4. Fonts, Manuals, and Terminfo
# --------------------------------------------------
echo "[4/5] Registering fonts, terminfo, and manpages..."
if [ -d "$HOME/.local/share/fonts" ] && command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true
fi

if [ -d "$HOME/.local/share/man" ] && command -v mandb >/dev/null 2>&1; then
    mandb -u -q "$HOME/.local/share/man" 2>/dev/null || mandb -u 2>/dev/null || true
fi

# --------------------------------------------------
# 5. Shell Activation & Health Check
# --------------------------------------------------
echo "[5/5] Configuring login shell and verifying health..."
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
    if zsh -c "exit 0" 2>/dev/null; then
        exec zsh
    fi
fi
BASH_EOF
            fi
        fi
    fi
fi

# Headless sanity tests
FAILURES=0
for cmd in rg fd fzf starship nvim lazygit zoxide bat delta tldr eza; do
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

# Clean up empty backup directory or report location
if [ -d "$BACKUP_DIR" ]; then
    if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        rm -rf "$BACKUP_DIR"
    else
        echo "[+] Colliding dotfiles safely backed up to: $BACKUP_DIR"
    fi
fi

if [ ! -f "$HOME/.gitconfig.local" ]; then
    echo "[!] Notice: ~/.gitconfig.local not found."
    echo "    Configure your Git identity with:"
    echo "      git config -f ~/.gitconfig.local user.name \"Your Name\""
    echo "      git config -f ~/.gitconfig.local user.email \"user@example.com\""
fi

echo "================================================="
if [ $FAILURES -eq 0 ]; then
    echo "  DEPLOYMENT COMPLETE: PARITY VERIFIED          "
else
    echo "  DEPLOYMENT FINISHED WITH $FAILURES ISSUES     "
fi
echo "================================================="
echo "Reload session: exec zsh"
