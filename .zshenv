# ==================================================
# Environment Variables (Sourced for all Zsh instances)
# ==================================================

# Locale
export LANG="${LANG:-en_US.UTF-8}"

# Default Editors
export EDITOR="nvim"
export VISUAL="nvim"

# Enforce unique entries in PATH
typeset -U path PATH

# Prepend custom directories with (N-/) to silently omit non-existent directories
path=(
  "$HOME/.local/bin"(N-/)
  "$HOME/.local/share/nvim/mason/bin"(N-/)
  "$HOME/.cargo/bin"(N-/)
  "$HOME/bin"(N-/)
  $path
)
export PATH
