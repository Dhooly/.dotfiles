# Keep user-installed tools ahead of system paths on every supported platform.
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  $path
)

# Homebrew is installed in different prefixes on Apple Silicon and Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

[[ -r "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"

