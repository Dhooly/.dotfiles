#!/usr/bin/env bash

set -Eeuo pipefail

DF_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PATH="$HOME/.local/bin:$PATH"
export PATH
DF_PROFILE='full'
DF_DRY_RUN=0
DF_ASSUME_YES=0
DF_SKIP_PACKAGES=0
DF_SKIP_SHELL_CHANGE=0
DF_SKIP_OH_MY_ZSH=0
DF_SKIP_TMUX_PLUGINS=0

# shellcheck source=scripts/lib/common.sh
. "$DF_ROOT/scripts/lib/common.sh"
# shellcheck source=scripts/lib/platform.sh
. "$DF_ROOT/scripts/lib/platform.sh"
# shellcheck source=scripts/lib/packages.sh
. "$DF_ROOT/scripts/lib/packages.sh"
# shellcheck source=scripts/lib/links.sh
. "$DF_ROOT/scripts/lib/links.sh"
# shellcheck source=scripts/lib/zsh.sh
. "$DF_ROOT/scripts/lib/zsh.sh"

usage()
{
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

Install packages, Oh My Zsh, and links for a fresh development machine.

Options:
  --profile NAME        Package profile: core, dev, or full (default: full)
  --dry-run             Print changes without making them
  --yes                 Do not ask for confirmation
  --skip-packages       Do not install operating-system packages
  --skip-oh-my-zsh      Do not install Oh My Zsh or its external plugins
  --skip-tmux-plugins   Do not install TPM or the configured tmux plugins
  --skip-shell-change   Do not change the account's default shell
  -h, --help            Show this help

Examples:
  ./bootstrap.sh --dry-run
  ./bootstrap.sh --profile dev
  ./bootstrap.sh --yes --profile full
EOF
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
      --dry-run)
        DF_DRY_RUN=1
        shift
        ;;
      --yes)
        DF_ASSUME_YES=1
        shift
        ;;
      --skip-packages)
        DF_SKIP_PACKAGES=1
        shift
        ;;
      --skip-oh-my-zsh)
        DF_SKIP_OH_MY_ZSH=1
        shift
        ;;
      --skip-tmux-plugins)
        DF_SKIP_TMUX_PLUGINS=1
        shift
        ;;
      --skip-shell-change)
        DF_SKIP_SHELL_CHANGE=1
        shift
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
      die "Invalid profile: $DF_PROFILE (expected core, dev, or full)"
      ;;
  esac

  export DF_ROOT DF_PROFILE DF_DRY_RUN DF_ASSUME_YES
}

main()
{
  parse_arguments "$@"
  detect_platform

  info 'Dotfiles bootstrap plan'
  platform_summary
  printf 'Profile          : %s\n' "$DF_PROFILE"
  printf 'Repository       : %s\n' "$DF_ROOT"
  if [ "$DF_DRY_RUN" -eq 1 ]; then
    printf 'Mode             : dry run\n'
  fi
  printf '\n'

  if ! confirm 'Continue with this setup?'; then
    info 'No changes made.'
    exit 0
  fi

  if [ "$DF_SKIP_PACKAGES" -eq 0 ]; then
    install_packages "$DF_PROFILE"
  else
    warn 'Skipping operating-system packages.'
  fi

  if [ "$DF_SKIP_OH_MY_ZSH" -eq 0 ]; then
    command_exists git || die 'git is required to install Oh My Zsh.'
    install_oh_my_zsh
  else
    warn 'Skipping Oh My Zsh.'
  fi

  if [ "$DF_SKIP_TMUX_PLUGINS" -eq 0 ]; then
    command_exists git || die 'git is required to install tmux plugins.'
    install_tmux_plugins
  else
    warn 'Skipping tmux plugins.'
  fi

  link_dotfiles

  if [ "$DF_SKIP_SHELL_CHANGE" -eq 0 ]; then
    set_default_shell
  else
    warn 'Skipping the default shell change.'
  fi

  printf '\n'
  success 'Bootstrap complete.'
  printf 'Run %s/scripts/doctor.sh to verify the installation.\n' "$DF_ROOT"
  printf 'Start a new terminal session to use Zsh.\n'
}

main "$@"

