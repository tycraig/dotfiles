#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
OUTPUT_DIR="${HOME}/bundles"
ARCHIVE_NAME="dev-bundle-${TIMESTAMP}.tar.gz"
LATEST_LINK="${OUTPUT_DIR}/dev-bundle-latest.tar.gz"

mkdir -p "$OUTPUT_DIR"

echo "==> Generating latest version manifest..."
"${HOME}/.local/bin/generate_manifest.sh"

echo "==> Optimizing payload sizes (stripping debug symbols)..."
# Strip local standalone ELF binaries
find "$HOME/.local/bin" -type f -exec file {} + 2>/dev/null | grep "ELF" | cut -d: -f1 | xargs -r strip --strip-unneeded 2>/dev/null || true

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
[ -d ".local/bin" ] && TARGETS+=(".local/bin")
[ -d ".local/opt" ] && TARGETS+=(".local/opt")
[ -f ".local/env-manifest.txt" ] && TARGETS+=(".local/env-manifest.txt")

# 3. Terminal, Shell, and Tooling Assets
[ -d ".terminfo" ] && TARGETS+=(".terminfo")
[ -d ".local/share/zsh" ] && TARGETS+=(".local/share/zsh")
[ -d ".local/share/fzf" ] && TARGETS+=(".local/share/fzf")
[ -d ".local/share/man" ] && TARGETS+=(".local/share/man")
[ -d ".local/share/fonts" ] && TARGETS+=(".local/share/fonts")
[ -d ".local/share/gef" ] && TARGETS+=(".local/share/gef")

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
    --exclude=".local/share/zsh/*/.git" \
    --exclude=".local/share/nvim/mason/staging" \
    -czf "${OUTPUT_DIR}/${ARCHIVE_NAME}" "${TARGETS[@]}"

ln -sf "${OUTPUT_DIR}/${ARCHIVE_NAME}" "$LATEST_LINK"

SIZE=$(du -h "${OUTPUT_DIR}/${ARCHIVE_NAME}" | cut -f1)
echo "================================================="
echo "SUCCESS: Optimized bundle created!"
echo "Archive: ${OUTPUT_DIR}/${ARCHIVE_NAME} ($SIZE)"
echo "Symlink: $LATEST_LINK"
echo "================================================="
