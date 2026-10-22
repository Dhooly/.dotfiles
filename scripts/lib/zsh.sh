#!/usr/bin/env bash

clone_if_missing()
{
  local repository_="$1"
  local destination_="$2"

  if [ -d "$destination_/.git" ]; then
    success "Already installed: $destination_"
    return 0
  fi

  if [ -e "$destination_" ]; then
    warn "Cannot install into an existing non-Git path: $destination_"
    return 0
  fi

  run git clone --depth=1 "$repository_" "$destination_"
}

install_oh_my_zsh()
{
  local zsh_root_="${ZSH:-$HOME/.oh-my-zsh}"
  local custom_root_="${ZSH_CUSTOM:-$zsh_root_/custom}"

  info 'Installing Oh My Zsh and plugins'
  clone_if_missing 'https://github.com/ohmyzsh/ohmyzsh.git' "$zsh_root_"
  clone_if_missing 'https://github.com/zsh-users/zsh-autosuggestions.git' "$custom_root_/plugins/zsh-autosuggestions"
  clone_if_missing 'https://github.com/zsh-users/zsh-syntax-highlighting.git' "$custom_root_/plugins/zsh-syntax-highlighting"
}

install_tmux_plugins()
{
  local plugins_root_="${TMUX_PLUGIN_MANAGER_PATH:-$HOME/.tmux/plugins}"

  info 'Installing tmux plugins'
  clone_if_missing 'https://github.com/tmux-plugins/tpm.git' "$plugins_root_/tpm"
  clone_if_missing 'https://github.com/tmux-plugins/tmux-sensible.git' "$plugins_root_/tmux-sensible"
  clone_if_missing 'https://github.com/nhdaly/tmux-better-mouse-mode.git' "$plugins_root_/tmux-better-mouse-mode"
  clone_if_missing 'https://github.com/pschmitt/tmux-ssh-split.git' "$plugins_root_/tmux-ssh-split"
}

set_default_shell()
{
  local zsh_path_
  zsh_path_="$(command -v zsh 2>/dev/null || true)"

  if [ -z "$zsh_path_" ]; then
    if [ "${DF_DRY_RUN:-0}" -eq 1 ]; then
      info 'Would set the newly installed Zsh as the default shell.'
      return 0
    fi
    warn 'zsh is not installed; the default shell was not changed.'
    return 0
  fi

  if ! command_exists chsh; then
    warn 'chsh is unavailable; set Zsh as the default shell manually.'
    return 0
  fi

  if [ "${SHELL:-}" = "$zsh_path_" ]; then
    success "zsh is already the default shell ($zsh_path_)"
    return 0
  fi

  if [ -r /etc/shells ] && ! grep -Fxq "$zsh_path_" /etc/shells; then
    info "Adding $zsh_path_ to /etc/shells"
    if [ "${DF_DRY_RUN:-0}" -eq 1 ]; then
      printf '    add %s to /etc/shells\n' "$zsh_path_"
    else
      printf '%s\n' "$zsh_path_" | run_as_root tee -a /etc/shells >/dev/null
    fi
  fi

  info "Changing the default shell to $zsh_path_"
  run chsh -s "$zsh_path_"
}

