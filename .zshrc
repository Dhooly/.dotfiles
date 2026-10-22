export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ZSH_THEME="robbyrussell"

# Graphical terminals on Linux often start a non-login shell, so keep these
# paths here as well as in .zprofile.
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  $path
)

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

plugins=(
  git
  colored-man-pages
  direnv
  fzf
  z
)

[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  print -P "%F{yellow}Oh My Zsh is not installed. Run ~/.dotfiles/bootstrap.sh.%f"
  autoload -Uz compinit && compinit
fi

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"

alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias g='git'
alias v='nvim'
alias vim='nvim'
alias reload='exec zsh'

if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza --group-directories-first --long --all --git'
  alias tree='eza --tree'
else
  alias ll='ls -lah'
fi

if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
elif (( $+commands[batcat] )); then
  alias bat='batcat'
  alias cat='batcat --paging=never'
fi

if ! (( $+commands[fd] )) && (( $+commands[fdfind] )); then
  alias fd='fdfind'
fi

if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

