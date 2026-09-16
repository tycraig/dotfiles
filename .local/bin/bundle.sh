#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
OUTPUT_DIR="${HOME}/bundles"
ARCHIVE_NAME="dev-bundle-${TIMESTAMP}.tar.gz"
LATEST_LINK="${OUTPUT_DIR}/dev-bundle-latest.tar.gz"

mkdir -p "$OUTPUT_DIR"

echo "==> Generating latest version manifest..."
"${HOME}/.local/bin/generate_manifest.sh"

echo "==> Preparing bundle paths..."
cd "$HOME"

TARGETS=()

# 1. Dotfiles Bare Git Repository
[ -d ".dotfiles" ] && TARGETS+=(".dotfiles")

# 2. Binaries, Neovim Runtime Tree, and Manifest
[ -d ".local/bin" ] && TARGETS+=(".local/bin")
[ -d ".local/opt" ] && TARGETS+=(".local/opt")
[ -f ".local/env-manifest.txt" ] && TARGETS+=(".local/env-manifest.txt")

# 3. Terminal & Shell Ergonomics
[ -d ".terminfo" ] && TARGETS+=(".terminfo")
[ -d ".local/share/zsh" ] && TARGETS+=(".local/share/zsh")
[ -d ".local/share/fzf" ] && TARGETS+=(".local/share/fzf")
[ -d ".local/share/man" ] && TARGETS+=(".local/share/man")
[ -d ".local/share/fonts" ] && TARGETS+=(".local/share/fonts")

# 4. Neovim Ecosystem (Lazy plugins, compiled Treesitter parsers, Mason tooling)
[ -d ".local/share/nvim/lazy" ] && TARGETS+=(".local/share/nvim/lazy")
[ -d ".local/share/nvim/mason" ] && TARGETS+=(".local/share/nvim/mason")

echo "==> Packaging payload:"
for target in "${TARGETS[@]}"; do
    echo "    - ~/${target}"
done

echo "==> Compressing archive to ${OUTPUT_DIR}/${ARCHIVE_NAME}..."
tar --exclude="*.log" \
    --exclude="*.tmp" \
    --exclude=".dotfiles/index.lock" \
    -czf "${OUTPUT_DIR}/${ARCHIVE_NAME}" "${TARGETS[@]}"

ln -sf "${OUTPUT_DIR}/${ARCHIVE_NAME}" "$LATEST_LINK"

SIZE=$(du -h "${OUTPUT_DIR}/${ARCHIVE_NAME}" | cut -f1)
echo "================================================="
echo "SUCCESS: Bundle created!"
echo "Archive: ${OUTPUT_DIR}/${ARCHIVE_NAME} ($SIZE)"
echo "Symlink: $LATEST_LINK"
echo "================================================="
