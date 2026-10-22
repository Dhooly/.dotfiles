#!/usr/bin/env bash

strip_trailing_slash()
{
  local path_="$1"
  while [ "$path_" != '/' ] && [ "${path_%/}" != "$path_" ]; do
    path_="${path_%/}"
  done
  printf '%s\n' "$path_"
}

canonical_existing_path()
{
  local path_="$1"
  local directory_
  local basename_

  if [ -d "$path_" ]; then
    (cd "$path_" && pwd -P)
    return
  fi

  directory_="$(dirname "$path_")"
  basename_="$(basename "$path_")"
  (cd "$directory_" && printf '%s/%s\n' "$(pwd -P)" "$basename_")
}

link_paths()
{
  local source_="$1"
  local target_="$2"
  local backup_relative_="$3"
  local label_="$4"
  local current_=''
  local current_path_=''
  local backup_="$DF_BACKUP_ROOT/$backup_relative_"

  if [ ! -e "$source_" ] && [ ! -L "$source_" ]; then
    warn "Dotfile source is missing: $source_"
    return 0
  fi

  if [ -L "$target_" ]; then
    current_="$(strip_trailing_slash "$(readlink "$target_")")"
    case "$current_" in
      /*)
        current_path_="$current_"
        ;;
      *)
        current_path_="$(dirname "$target_")/$current_"
        ;;
    esac

    if [ -e "$current_path_" ] &&
      [ "$(canonical_existing_path "$current_path_")" = "$(canonical_existing_path "$source_")" ]; then
      success "$label_ is already linked"
      return 0
    fi
  fi

  if [ -e "$target_" ] || [ -L "$target_" ]; then
    info "Backing up $target_ to $backup_"
    run mkdir -p "$(dirname "$backup_")"
    run mv "$target_" "$backup_"
  fi

  run mkdir -p "$(dirname "$target_")"
  run ln -s "$source_" "$target_"
  success "Linked $label_"
}

link_one()
{
  local relative_="$1"
  link_paths "$DF_ROOT/$relative_" "$HOME/$relative_" "$relative_" "$relative_"
}

preserve_local_git_config()
{
  local current_="$HOME/.gitconfig"
  local local_="$HOME/.gitconfig.local"

  if [ -f "$current_" ] && [ ! -L "$current_" ] && [ ! -e "$local_" ]; then
    if grep -Fq '.gitconfig.local' "$current_"; then
      warn 'The existing .gitconfig already references .gitconfig.local; only the timestamped backup will be created.'
      return 0
    fi
    info "Preserving the existing Git configuration in $local_"
    run cp -p "$current_" "$local_"
  fi
}

prepare_ghostty_config_directory()
{
  local directory_="$HOME/.config/ghostty"
  local repository_directory_="$DF_ROOT/.config/ghostty"
  local current_=''
  local current_path_=''
  local backup_="$DF_BACKUP_ROOT/.config/ghostty-directory-link"

  if [ ! -L "$directory_" ]; then
    return 0
  fi

  current_="$(strip_trailing_slash "$(readlink "$directory_")")"
  case "$current_" in
    /*)
      current_path_="$current_"
      ;;
    *)
      current_path_="$(dirname "$directory_")/$current_"
      ;;
  esac

  if [ ! -e "$current_path_" ] ||
    [ "$(canonical_existing_path "$current_path_")" != "$(canonical_existing_path "$repository_directory_")" ]; then
    return 0
  fi

  info 'Migrating the Ghostty directory link to a config-file link'
  run mkdir -p "$(dirname "$backup_")"
  run mv "$directory_" "$backup_"
  run mkdir -p "$directory_"
}

link_ghostty_themes()
{
  local source_
  local theme_

  if [ ! -d "$DF_ROOT/.config/ghostty/themes" ]; then
    return 0
  fi

  for source_ in "$DF_ROOT"/.config/ghostty/themes/*; do
    if [ ! -f "$source_" ]; then
      continue
    fi

    theme_="$(basename "$source_")"
    link_paths \
      "$source_" \
      "$HOME/.config/ghostty/themes/$theme_" \
      ".config/ghostty/themes/$theme_" \
      "Ghostty theme: $theme_"
  done
}

link_dotfiles()
{
  local relative_
  local links_=(
    .config/nvim
    .gitconfig
    .tmux.conf
    .zprofile
    .zshrc
  )

  DF_BACKUP_ROOT="$HOME/.dotfiles-backup/$(date '+%Y%m%d-%H%M%S')"
  export DF_BACKUP_ROOT

  info 'Linking dotfiles'
  preserve_local_git_config
  prepare_ghostty_config_directory
  link_paths \
    "$DF_ROOT/.config/ghostty/config" \
    "$HOME/.config/ghostty/config" \
    '.config/ghostty/config' \
    'Ghostty config'
  link_ghostty_themes
  for relative_ in "${links_[@]}"; do
    link_one "$relative_"
  done

  link_paths \
    "$DF_ROOT/bin/dotfiles-copy" \
    "$HOME/.local/bin/dotfiles-copy" \
    '.local/bin/dotfiles-copy' \
    'clipboard helper'

  if [ "${DF_OS:-}" = 'macos' ]; then
    link_paths \
      "$DF_ROOT/.config/ghostty/config" \
      "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" \
      'Library/Application Support/com.mitchellh.ghostty/config.ghostty' \
      'Ghostty macOS config'
  fi
}

