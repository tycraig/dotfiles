#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
OUTPUT_DIR="${HOME}/bundles"
ARCHIVE_NAME="dev-bundle-${TIMESTAMP}.tar.zst"
LATEST_LINK="${OUTPUT_DIR}/dev-bundle-latest.tar.zst"

mkdir -p "$OUTPUT_DIR"

BIN_WHITELIST=(
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

echo "==> Generating latest version manifest..."
"${HOME}/.local/bin/generate_manifest.sh"

echo "==> Optimizing payload sizes (stripping debug symbols)..."
# Strip local standalone ELF binaries
for bin in "${BIN_WHITELIST[@]}"; do
    bin_path="$HOME/.local/bin/$bin"
    if [ -f "$bin_path" ] && [ ! -L "$bin_path" ]; then
        if file "$bin_path" 2>/dev/null | grep -q "ELF"; then
            strip --strip-unneeded "$bin_path" 2>/dev/null || true
        fi
    fi
done

# Strip Mason language servers and debuggers (spares large space on liblldb / clangd)
if [ -d "$HOME/.local/share/nvim/mason/packages" ]; then
    find "$HOME/.local/share/nvim/mason/packages" -type f -exec file {} + 2>/dev/null | grep -E "ELF.*(executable|shared object)" | cut -d: -f1 | xargs -r strip --strip-unneeded 2>/dev/null || true
fi

echo "==> Preparing bundle targets..."
cd "$HOME"

TARGETS=()

# 1. Dotfiles Bare Git Repository
[ -d ".dotfiles" ] && TARGETS+=(".dotfiles")

# 2. Binaries, Runtime Trees, and Manifest
for bin in "${BIN_WHITELIST[@]}"; do
    if [ -e ".local/bin/$bin" ] || [ -L ".local/bin/$bin" ]; then
        TARGETS+=(".local/bin/$bin")
    fi
done
[ -d ".local/opt" ] && TARGETS+=(".local/opt")
[ -f ".local/env-manifest.txt" ] && TARGETS+=(".local/env-manifest.txt")

# 3. Terminal, Shell, and Tooling Assets
[ -d ".terminfo" ] && TARGETS+=(".terminfo")
[ -d ".local/share/zsh" ] && TARGETS+=(".local/share/zsh")
[ -d ".local/share/fzf" ] && TARGETS+=(".local/share/fzf")
[ -d ".local/share/man" ] && TARGETS+=(".local/share/man")
[ -d ".local/share/fonts" ] && TARGETS+=(".local/share/fonts")
[ -d ".local/share/gef" ] && TARGETS+=(".local/share/gef")
[ -d ".cache/tealdeer" ] && TARGETS+=(".cache/tealdeer")

# 4. Neovim Ecosystem (Lazy plugins, compiled Treesitter parsers, Mason packages)
[ -d ".local/share/nvim/lazy" ] && TARGETS+=(".local/share/nvim/lazy")
[ -d ".local/share/nvim/mason" ] && TARGETS+=(".local/share/nvim/mason")

echo "==> Packaging payload targets:"
for target in "${TARGETS[@]}"; do
    echo "    - ~/${target}"
done

echo "==> Compressing archive to ${OUTPUT_DIR}/${ARCHIVE_NAME}..."
tar --exclude="*.log" \
    --exclude="*.tmp" \
    --exclude="*.pyc" \
    --exclude="__pycache__" \
    --exclude=".dotfiles/index.lock" \
    --exclude=".local/share/nvim/lazy/*/.git" \
    --exclude=".local/share/nvim/lazy/*/tests" \
    --exclude=".local/share/nvim/lazy/*/spec" \
    --exclude=".local/share/nvim/lazy/*/.github" \
    --exclude=".local/share/zsh/*/.git" \
    --exclude=".local/share/nvim/mason/staging" \
    -I 'zstd -19 -T0' \
    -cf "${OUTPUT_DIR}/${ARCHIVE_NAME}" "${TARGETS[@]}"

ln -sf "${OUTPUT_DIR}/${ARCHIVE_NAME}" "$LATEST_LINK"

echo "==> Generating SHA-256 checksums..."
(cd "${OUTPUT_DIR}" && sha256sum "${ARCHIVE_NAME}" > "${ARCHIVE_NAME}.sha256")
(cd "${OUTPUT_DIR}" && sha256sum "dev-bundle-latest.tar.zst" > "dev-bundle-latest.tar.zst.sha256")

if [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo "==> Signing bundle with SSH key (~/.ssh/id_ed25519)..."
    ssh-keygen -Y sign -f "$HOME/.ssh/id_ed25519" -n file "${OUTPUT_DIR}/${ARCHIVE_NAME}" 2>/dev/null || true
    if [ -f "${OUTPUT_DIR}/${ARCHIVE_NAME}.sig" ]; then
        ln -sf "${OUTPUT_DIR}/${ARCHIVE_NAME}.sig" "${OUTPUT_DIR}/dev-bundle-latest.tar.zst.sig"
    fi
fi

SIZE=$(du -h "${OUTPUT_DIR}/${ARCHIVE_NAME}" | cut -f1)
echo "================================================="
echo "SUCCESS: Optimized bundle created!"
echo "Archive:   ${OUTPUT_DIR}/${ARCHIVE_NAME} ($SIZE)"
echo "Checksum:  ${OUTPUT_DIR}/${ARCHIVE_NAME}.sha256"
[ -f "${OUTPUT_DIR}/${ARCHIVE_NAME}.sig" ] && echo "Signature: ${OUTPUT_DIR}/${ARCHIVE_NAME}.sig"
echo "Symlink:   $LATEST_LINK"
echo "================================================="
