# ==================================================
# Interactive Shell Configuration
# Note: Core PATH, locale, and editors are defined in ~/.zshenv
# ==================================================

# ==================================================
# History
# ==================================================

HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY       # Write timestamps and run duration to history
setopt SHARE_HISTORY          # Share history across all windows
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when pruning history
setopt HIST_IGNORE_DUPS       # Don't record entry if it matches previous one
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicate entry if new one is recorded
setopt HIST_FIND_NO_DUPS      # Do not display duplicate entries during search
setopt HIST_SAVE_NO_DUPS      # Do not write duplicate events to history file
setopt HIST_IGNORE_SPACE      # Leading space prevents commands from being recorded
setopt HIST_VERIFY            # Don't execute immediately upon history expansion

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
bindkey -M viins 'jk' vi-cmd-mode
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

# Auto-activate / deactivate Python virtual environments
autoload -Uz add-zsh-hook
python_venv() {
    if [[ -n "$VIRTUAL_ENV" && ! -d "./.venv" ]]; then
        deactivate 2>/dev/null
    elif [[ -z "$VIRTUAL_ENV" && -d "./.venv" ]]; then
        source ./.venv/bin/activate 2>/dev/null
    fi
}
add-zsh-hook chpwd python_venv

# ==================================================
# Completion Settings
# ==================================================

# Add my site-functions to fpath before compinit
fpath=("$HOME/.local/share/zsh/site-functions" $fpath)

# Accelerate completion initialization with 24-hour cache check
autoload -Uz compinit
if () {
    setopt local_options extended_glob
    [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]
}; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # Case-insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"       # Match colors to LS_COLORS

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

# Tokyo Night theme for fzf
export FZF_DEFAULT_OPTS="--highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:#283457 \
  --color=bg:#16161e \
  --color=border:#27a1b9 \
  --color=fg:#c0caf5 \
  --color=gutter:#16161e \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#27a1b9 \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c"

# Use bat for fzf file preview and manual pager if available
if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :300 {}'"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

# ==================================================
# Aliases
# ==================================================

# Core editor & file management
alias vim="nvim"
alias v="nvim"
if command -v eza >/dev/null 2>&1; then
    alias ls="eza -F --icons=auto"
    alias ll="eza -laF --git --icons=auto"
    alias lt="eza --tree --level=2 --icons=auto"
else
    alias ls="ls --color=auto"
    alias ll="ls -lah --color=auto"
fi
alias grep="grep --color=auto"

# Shell ergonomics (friend's additions & POSIX helpers)
alias sudo='sudo '            # Expand aliases after sudo
alias c='clear'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir="mkdir -p"
alias history='history 0'     # Full history from beginning
alias python='python3'

# Create directory and change into it
mcd() {
    mkdir -p "$1" && cd "$1"
}

# System inspection shortcuts
alias path='print -l $path'
alias ports='ss -tulanp'
alias mem='free -h'
alias df='df -h'
alias du1='du -h -d 1'

# Tool fallbacks matching documentation
command -v bat >/dev/null 2>&1 && alias cat="bat --paging=never"
command -v fd  >/dev/null 2>&1 && alias find="fd"

# Bare Dotfiles repository shortcuts
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lg="lazygit"
alias dotgit="lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias dfs='dotfiles status'
alias dfa='dotfiles add'
alias dfc='dotfiles commit'
alias dfd='dotfiles diff'
alias dfp='dotfiles push'
alias dfl='dotfiles log --oneline -n 20'

# Standard Git shortcuts
alias g='git'
alias gst='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --graph --oneline --decorate -n 20'
alias gp='git push'

# Offline bundle maintenance
alias bundle-create='~/.local/bin/bundle.sh'
alias bundle-manifest='~/.local/bin/generate_manifest.sh'
alias bundle-sync='~/.local/bin/update.sh'

# ==================================================
# Plugins 
# ==================================================

[ -f ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ==================================================
# Prompt & Integrations
# ==================================================

eval "$(starship init zsh)"

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Source machine-specific local overrides if present
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
