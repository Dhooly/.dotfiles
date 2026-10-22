#!/usr/bin/env bash

set -u

DF_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
DF_FAILURES=0
DF_WARNINGS=0
DF_PROFILE='full'

# shellcheck source=lib/common.sh
. "$DF_ROOT/scripts/lib/common.sh"
# shellcheck source=lib/links.sh
. "$DF_ROOT/scripts/lib/links.sh"
# shellcheck source=lib/packages.sh
. "$DF_ROOT/scripts/lib/packages.sh"

usage()
{
  cat <<'EOF'
Usage: scripts/doctor.sh [--profile core|dev|full]

Check commands, configuration links, Oh My Zsh, and the default shell.
EOF
}

check_command()
{
  local label_="$1"
  shift
  local command_

  for command_ in "$@"; do
    if command_exists "$command_"; then
      success "$label_ ($command_)"
      return 0
    fi
  done

  warn "Missing: $label_"
  DF_FAILURES=$((DF_FAILURES + 1))
}

check_optional_command()
{
  local label_="$1"
  shift
  local command_

  for command_ in "$@"; do
    if command_exists "$command_"; then
      success "$label_ ($command_)"
      return 0
    fi
  done

  warn "Optional tool not found: $label_"
  DF_WARNINGS=$((DF_WARNINGS + 1))
}

check_link_paths()
{
  local target_="$1"
  local expected_="$2"
  local label_="$3"
  local actual_=''
  local actual_path_=''

  if [ -L "$target_" ]; then
    actual_="$(readlink "$target_")"
    case "$actual_" in
      /*)
        actual_path_="$actual_"
        ;;
      *)
        actual_path_="$(dirname "$target_")/$actual_"
        ;;
    esac

    if [ -e "$actual_path_" ] &&
      [ "$(canonical_existing_path "$actual_path_")" = "$(canonical_existing_path "$expected_")" ]; then
      success "$label_ is linked"
      return 0
    fi
  fi

  warn "Not linked to this repository: $target_"
  DF_FAILURES=$((DF_FAILURES + 1))
}

check_link()
{
  local relative_="$1"
  check_link_paths "$HOME/$relative_" "$DF_ROOT/$relative_" "$relative_"
}

check_ghostty_themes()
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
    check_link_paths \
      "$HOME/.config/ghostty/themes/$theme_" \
      "$source_" \
      "Ghostty theme: $theme_"
  done
}

parse_arguments()
{
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --profile)
        [ "$#" -ge 2 ] || die '--profile requires a value.'
        DF_PROFILE="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
  done

  case "$DF_PROFILE" in
    core|dev|full)
      ;;
    *)
      die "Invalid profile: $DF_PROFILE"
      ;;
  esac
}

main()
{
  local relative_
  local links_=(.config/nvim .gitconfig .tmux.conf .zprofile .zshrc)

  parse_arguments "$@"

  info 'Required commands'
  check_command 'Zsh' zsh
  check_command 'Git' git
  check_command 'Neovim' nvim
  check_command 'tmux' tmux
  check_command 'ripgrep' rg
  check_command 'fuzzy finder' fzf
  check_command 'JSON processor' jq

  if command_exists nvim; then
    if neovim_is_current; then
      success "Neovim version is supported ($(nvim --version | sed -n '1p'))"
    else
      warn "Neovim 0.11 or newer is required ($(nvim --version | sed -n '1p'))"
      DF_FAILURES=$((DF_FAILURES + 1))
    fi
  fi

  if [ "$DF_PROFILE" = 'dev' ] || [ "$DF_PROFILE" = 'full' ]; then
    info 'Development commands'
    check_command 'C compiler' clang gcc cc
    check_command 'C++ compiler' clang++ g++ c++
    check_command 'CMake' cmake
    check_command 'Ninja' ninja
    check_command 'Python' python3 python
    check_command 'Node.js' node
    check_command 'ShellCheck' shellcheck
  fi

  info 'Recommended commands'
  check_optional_command 'bat' bat batcat
  check_optional_command 'fd' fd fdfind
  check_optional_command 'GitHub CLI' gh
  check_optional_command 'lazygit' lazygit
  check_optional_command 'modern ls' eza
  check_optional_command 'pnpm' pnpm
  check_optional_command 'zoxide' zoxide

  if [ "$DF_PROFILE" = 'full' ]; then
    info 'Fonts'
    if monaco_for_powerline_is_installed; then
      success 'Monaco for Powerline is installed'
    else
      warn 'Monaco for Powerline is not installed'
      DF_FAILURES=$((DF_FAILURES + 1))
    fi
  fi

  info 'Configuration links'
  check_link_paths \
    "$HOME/.config/ghostty/config" \
    "$DF_ROOT/.config/ghostty/config" \
    'Ghostty config'
  check_ghostty_themes
  for relative_ in "${links_[@]}"; do
    check_link "$relative_"
  done
  check_link_paths \
    "$HOME/.local/bin/dotfiles-copy" \
    "$DF_ROOT/bin/dotfiles-copy" \
    'clipboard helper'
  if [ "$(uname -s)" = 'Darwin' ]; then
    check_link_paths \
      "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" \
      "$DF_ROOT/.config/ghostty/config" \
      'Ghostty macOS config'
  fi

  info 'Shell configuration'
  if [ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    success 'Oh My Zsh is installed'
  else
    warn 'Oh My Zsh is not installed'
    DF_FAILURES=$((DF_FAILURES + 1))
  fi

  if [ -x "$HOME/.tmux/plugins/tpm/tpm" ]; then
    success 'tmux Plugin Manager is installed'
  else
    warn 'tmux Plugin Manager is not installed'
    DF_FAILURES=$((DF_FAILURES + 1))
  fi

  case "${SHELL:-}" in
    */zsh)
      success "Default shell is Zsh ($SHELL)"
      ;;
    *)
      warn "Default shell is not Zsh (SHELL=${SHELL:-unset})"
      DF_FAILURES=$((DF_FAILURES + 1))
      ;;
  esac

  printf '\n'
  if [ "$DF_FAILURES" -gt 0 ]; then
    die "$DF_FAILURES required checks failed; $DF_WARNINGS optional tools are missing."
  fi

  success "All required checks passed; $DF_WARNINGS optional tools are missing."
}

main "$@"

