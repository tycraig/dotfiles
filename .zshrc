# ==================================================
# Environment Variables
# ==================================================

# Enforce unique entries in PATH (prevents duplicates on re-sourcing)
typeset -U path PATH

# Prepend custom directories in order of execution priority
path=(
  "$HOME/.cargo/bin"
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.local/share/nvim/mason/bin"
  $path
)
export PATH

export EDITOR="nvim"
export VISUAL="nvim"

# ==================================================
# History
# ==================================================

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt EXTENDED_HISTORY 	# Write timestamps and run duration to history
setopt SHARE_HISTORY		# Share history across all windows
setopt HIST_EXPIRE_DUPS_FIRST	# Expire duplicate entries first when pruning history
setopt HIST_IGNORE_DUPS		# Don't record entry if it matches previous one
setopt HIST_IGNORE_SPACE	# Leading space prevents commands from being recoreded
setopt HIST_VERIFY		# Don't execute immediately

# ==================================================
# Shell Options 
# ==================================================

setopt autocd 
setopt autopushd
setopt pushd_ignore_dups
setopt nomatch
setopt notify
setopt interactivecomments

unsetopt extendedglob

# Set vi keybinding mode
bindkey -v
export KEYTIMEOUT=1

function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
	printf '\e[2 q'
    else
	printf '\e[5 q'
    fi
}
zle -N zle-keymap-select
precmd_functions+=(zle-keymap-select)

# ==================================================
# Completion Settings
# ==================================================

# Add my site-functions to fpath before compinit
fpath=(~/.local/share/zsh/site-functions $fpath)

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive tab completion

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
alias ls="ls --color=auto"
alias ll="ls -lah --color=auto"
alias grep="grep --color=auto"

# Alias to interact with dotfiles repo
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# ==================================================
# Plugins 
# ==================================================

[ -f ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ==================================================
# Prompt
# ==================================================

eval "$(starship init zsh)"
