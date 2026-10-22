#!/usr/bin/env bash

# Shared logging and command helpers. This file intentionally supports the
# Bash 3.2 shipped with macOS.

if [ -t 1 ]; then
  DF_COLOR_BLUE='\033[0;34m'
  DF_COLOR_GREEN='\033[0;32m'
  DF_COLOR_YELLOW='\033[0;33m'
  DF_COLOR_RED='\033[0;31m'
  DF_COLOR_RESET='\033[0m'
else
  DF_COLOR_BLUE=''
  DF_COLOR_GREEN=''
  DF_COLOR_YELLOW=''
  DF_COLOR_RED=''
  DF_COLOR_RESET=''
fi

info()
{
  printf '%b==>%b %s\n' "$DF_COLOR_BLUE" "$DF_COLOR_RESET" "$*"
}

success()
{
  printf '%b ok%b %s\n' "$DF_COLOR_GREEN" "$DF_COLOR_RESET" "$*"
}

warn()
{
  printf '%bwarn%b %s\n' "$DF_COLOR_YELLOW" "$DF_COLOR_RESET" "$*" >&2
}

die()
{
  printf '%berror%b %s\n' "$DF_COLOR_RED" "$DF_COLOR_RESET" "$*" >&2
  exit 1
}

command_exists()
{
  command -v "$1" >/dev/null 2>&1
}

print_command()
{
  printf '    '
  printf '%q ' "$@"
  printf '\n'
}

run()
{
  if [ "${DF_DRY_RUN:-0}" -eq 1 ]; then
    print_command "$@"
    return 0
  fi

  "$@"
}

run_as_root()
{
  if [ "$(id -u)" -eq 0 ]; then
    run "$@"
  elif command_exists sudo; then
    run sudo "$@"
  else
    die "This step requires root privileges, but sudo is unavailable: $*"
  fi
}

confirm()
{
  local prompt_="$1"
  local answer

  if [ "${DF_ASSUME_YES:-0}" -eq 1 ] || [ "${DF_DRY_RUN:-0}" -eq 1 ]; then
    return 0
  fi

  if [ ! -t 0 ]; then
    die "Cannot prompt for confirmation. Re-run with --yes in a noninteractive shell."
  fi

  printf '%s [y/N] ' "$prompt_"
  read -r answer
  case "$answer" in
    y|Y|yes|YES|Yes)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

