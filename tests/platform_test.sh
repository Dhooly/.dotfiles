#!/usr/bin/env bash

set -eu

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_TMP="$(mktemp -d)"
trap 'rm -rf "${TEST_TMP:?}"' EXIT HUP INT TERM

# shellcheck source=../scripts/lib/common.sh
. "$TEST_ROOT/scripts/lib/common.sh"
# shellcheck source=../scripts/lib/platform.sh
. "$TEST_ROOT/scripts/lib/platform.sh"
# shellcheck source=../scripts/lib/packages.sh
. "$TEST_ROOT/scripts/lib/packages.sh"

assert_equal()
{
  local expected_="$1"
  local actual_="$2"
  local label_="$3"

  if [ "$expected_" != "$actual_" ]; then
    printf 'FAIL: %s: expected %s, got %s\n' "$label_" "$expected_" "$actual_" >&2
    exit 1
  fi
}

assert_array_contains()
{
  local expected_="$1"
  shift
  local value_

  for value_ in "$@"; do
    [ "$value_" = "$expected_" ] && return 0
  done

  printf 'FAIL: package list does not contain %s\n' "$expected_" >&2
  exit 1
}

assert_array_excludes()
{
  local unexpected_="$1"
  shift
  local value_

  for value_ in "$@"; do
    if [ "$value_" = "$unexpected_" ]; then
      printf 'FAIL: package list unexpectedly contains %s\n' "$unexpected_" >&2
      exit 1
    fi
  done
}

write_os_release()
{
  local id_="$1"
  local like_="$2"
  printf 'ID=%s\nID_LIKE="%s"\n' "$id_" "$like_" > "$TEST_TMP/os-release"
}

test_linux_distribution()
{
  local id_="$1"
  local like_="$2"
  local expected_family_="$3"
  local expected_manager_="$4"

  write_os_release "$id_" "$like_"
  DOTFILES_UNAME_OVERRIDE='Linux'
  DOTFILES_OS_RELEASE_FILE="$TEST_TMP/os-release"
  detect_platform

  assert_equal "$id_" "$DF_OS" "$id_ OS"
  assert_equal "$expected_family_" "$DF_FAMILY" "$id_ family"
  assert_equal "$expected_manager_" "$DF_PACKAGE_MANAGER" "$id_ package manager"
}

test_linux_distribution cachyos arch arch pacman
test_linux_distribution fedora '' fedora dnf
test_linux_distribution ubuntu debian debian apt
test_linux_distribution debian '' debian apt
test_linux_distribution pop 'ubuntu debian' debian apt

test_linux_distribution cachyos arch arch pacman
select_packages core
assert_array_contains zsh "${DF_PACKAGES[@]}"
assert_array_excludes ghostty "${DF_PACKAGES[@]}"
select_packages full
assert_array_contains ghostty "${DF_PACKAGES[@]}"
assert_array_contains ttf-meslo-nerd "${DF_PACKAGES[@]}"

# Exercise the complete CachyOS path without requiring Pacman on the CI host.
mkdir -p "$TEST_TMP/home"
write_os_release cachyos arch
HOME="$TEST_TMP/home" \
  DOTFILES_UNAME_OVERRIDE='Linux' \
  DOTFILES_OS_RELEASE_FILE="$TEST_TMP/os-release" \
  "$TEST_ROOT/bootstrap.sh" \
    --dry-run --yes --skip-oh-my-zsh --skip-tmux-plugins --skip-shell-change >/dev/null 2>&1

DOTFILES_UNAME_OVERRIDE='Darwin'
DOTFILES_OS_RELEASE_FILE="$TEST_TMP/does-not-exist"
detect_platform
assert_equal macos "$DF_OS" 'macOS OS'
assert_equal brew "$DF_PACKAGE_MANAGER" 'macOS package manager'

printf 'All platform detection tests passed.\n'

