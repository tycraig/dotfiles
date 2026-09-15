# ==================================================
# Environment Variables
# ==================================================

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# ==================================================
# Shell Options / History
# ==================================================

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt autocd beep nomatch notify
unsetopt extendedglob

# Set vi keybinding mode
bindkey -v

# ==================================================
# Completion Settings
# ==================================================

# Add my site-functions to fpath before compinit
fpath=(~/.local/share/zsh/site-functions $fpath)

zstyle :compinstall filename '/home/tyler/.zshrc'
autoload -Uz compinit
compinit


# ==================================================
# Tool Integrations
# ==================================================

# Load fzf completions and keybindings
[ -f ~/.local/share/fzf/completion.zsh ] && source ~/.local/share/fzf/completion.zsh
[ -f ~/.local/share/fzf/key-bindings.zsh ] && source ~/.local/share/fzf/key-bindings.zsh

# Ensure fzf search keybindings work in Vim normal mode and insert mode
if (( $+widgets[fzf-history-widget] )); then
    bindkey -M vicmd '^R' fzf-history-widget
    bindkey -M vicmd '^T' fzf-file-widget
fi

# ==================================================
# Aliases
# ==================================================

alias vim="nvim"
alias v="nvim"

# Alias to interact with dotfiles repo
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# ==================================================
# Prompt
# ==================================================

eval "$(starship init zsh)"
