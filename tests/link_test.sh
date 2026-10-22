#!/usr/bin/env bash

set -eu

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_TMP="$(mktemp -d)"
TEST_HOME="$TEST_TMP/home"
TEST_OS_RELEASE="$TEST_TMP/os-release"
trap 'rm -rf "${TEST_TMP:?}"' EXIT HUP INT TERM

mkdir -p "$TEST_HOME"
printf 'ID=cachyos\nID_LIKE=arch\n' > "$TEST_OS_RELEASE"
printf 'original git configuration\n' > "$TEST_HOME/.gitconfig"

run_bootstrap()
{
  HOME="$TEST_HOME" \
    DOTFILES_UNAME_OVERRIDE='Linux' \
    DOTFILES_OS_RELEASE_FILE="$TEST_OS_RELEASE" \
    "$TEST_ROOT/bootstrap.sh" \
      --yes \
      --profile core \
      --skip-packages \
      --skip-oh-my-zsh \
      --skip-tmux-plugins \
      --skip-shell-change >/dev/null 2>&1
}

run_bootstrap

[ -L "$TEST_HOME/.zshrc" ] || { printf 'FAIL: .zshrc was not linked\n' >&2; exit 1; }
[ "$(readlink "$TEST_HOME/.zshrc")" = "$TEST_ROOT/.zshrc" ] || {
  printf 'FAIL: .zshrc points to the wrong source\n' >&2
  exit 1
}
[ "$(readlink "$TEST_HOME/.local/bin/dotfiles-copy")" = "$TEST_ROOT/bin/dotfiles-copy" ] || {
  printf 'FAIL: clipboard helper points to the wrong source\n' >&2
  exit 1
}
[ -f "$TEST_HOME/.gitconfig.local" ] || { printf 'FAIL: .gitconfig.local was not preserved\n' >&2; exit 1; }
grep -Fxq 'original git configuration' "$TEST_HOME/.gitconfig.local" || {
  printf 'FAIL: .gitconfig.local does not contain the original config\n' >&2
  exit 1
}

backup_found_=0
for backup_ in "$TEST_HOME"/.dotfiles-backup/*/.gitconfig; do
  if [ -f "$backup_" ] && grep -Fxq 'original git configuration' "$backup_"; then
    backup_found_=1
  fi
done
[ "$backup_found_" -eq 1 ] || { printf 'FAIL: existing .gitconfig was not backed up\n' >&2; exit 1; }

# A second run must recognize its own links and leave them in place.
run_bootstrap
[ "$(readlink "$TEST_HOME/.gitconfig")" = "$TEST_ROOT/.gitconfig" ] || {
  printf 'FAIL: bootstrap was not idempotent\n' >&2
  exit 1
}

# macOS uses an additional, platform-native Ghostty configuration path.
HOME="$TEST_HOME" \
  DOTFILES_UNAME_OVERRIDE='Darwin' \
  "$TEST_ROOT/bootstrap.sh" \
    --yes \
    --profile core \
    --skip-packages \
    --skip-oh-my-zsh \
    --skip-tmux-plugins \
    --skip-shell-change >/dev/null 2>&1

macos_ghostty_="$TEST_HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
[ -L "$macos_ghostty_" ] || { printf 'FAIL: macOS Ghostty config was not linked\n' >&2; exit 1; }
[ "$(readlink "$macos_ghostty_")" = "$TEST_ROOT/.config/ghostty/config" ] || {
  printf 'FAIL: macOS Ghostty config points to the wrong source\n' >&2
  exit 1
}

printf 'All link and backup tests passed.\n'

