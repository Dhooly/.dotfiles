#!/usr/bin/env bash

ensure_homebrew()
{
  local brew_command_=''
  local brew_environment_=''
  local installer_=''

  if command_exists brew; then
    brew_command_="$(command -v brew)"
  elif [ -x /opt/homebrew/bin/brew ]; then
    brew_command_='/opt/homebrew/bin/brew'
  elif [ -x /usr/local/bin/brew ]; then
    brew_command_='/usr/local/bin/brew'
  else
    info 'Installing Homebrew'
    if [ "${DF_DRY_RUN:-0}" -eq 1 ]; then
      printf '    /bin/bash -c <Homebrew installer>\n'
      return 0
    fi

    command_exists curl || die 'curl is required to install Homebrew.'
    installer_="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || die 'Could not download the Homebrew installer.'
    NONINTERACTIVE=1 /bin/bash -c "$installer_"

    if [ -x /opt/homebrew/bin/brew ]; then
      brew_command_='/opt/homebrew/bin/brew'
    elif [ -x /usr/local/bin/brew ]; then
      brew_command_='/usr/local/bin/brew'
    else
      die 'Homebrew finished installing, but brew could not be found.'
    fi
  fi

  brew_environment_="$("$brew_command_" shellenv)" || die 'Could not load the Homebrew environment.'
  eval "$brew_environment_"
}

package_available()
{
  local package_="$1"

  case "$DF_PACKAGE_MANAGER" in
    brew)
      return 0
      ;;
    pacman)
      pacman -Si "$package_" >/dev/null 2>&1 || pacman -Qi "$package_" >/dev/null 2>&1
      ;;
    apt)
      apt-cache show "$package_" >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}

filter_available_packages()
{
  local package_
  DF_AVAILABLE_PACKAGES=()

  if [ "$DF_PACKAGE_MANAGER" = 'brew' ] || [ "$DF_PACKAGE_MANAGER" = 'dnf' ]; then
    DF_AVAILABLE_PACKAGES=("$@")
    return 0
  fi

  if [ "${DF_DRY_RUN:-0}" -eq 1 ] && ! command_exists "$DF_PACKAGE_MANAGER"; then
    DF_AVAILABLE_PACKAGES=("$@")
    return 0
  fi

  for package_ in "$@"; do
    if package_available "$package_"; then
      DF_AVAILABLE_PACKAGES+=("$package_")
    else
      warn "Package is unavailable on $DF_OS and will be skipped: $package_"
    fi
  done
}

neovim_is_current()
{
  local version_=''
  local major_=''
  local remainder_=''
  local minor_=''

  command_exists nvim || return 1
  version_="$(nvim --version 2>/dev/null | sed -n '1p')"
  version_="${version_#NVIM v}"
  major_="${version_%%.*}"
  remainder_="${version_#*.}"
  minor_="${remainder_%%.*}"

  case "$major_:$minor_" in
    *[!0-9:]*|:|*:)
      return 1
      ;;
  esac

  [ "$major_" -gt 0 ] || [ "$minor_" -ge 11 ]
}

install_current_neovim_for_linux()
{
  local machine_=''
  local asset_arch_=''
  local archive_name_=''
  local download_url_=''
  local install_parent_="$HOME/.local/opt"
  local install_root_="$install_parent_/nvim"
  local binary_link_="$HOME/.local/bin/nvim"
  local timestamp_=''

  machine_="$(uname -m)"
  timestamp_="$(date '+%Y%m%d-%H%M%S')"

  case "$machine_" in
    x86_64|amd64)
      asset_arch_='x86_64'
      ;;
    aarch64|arm64)
      asset_arch_='arm64'
      ;;
    *)
      warn "Cannot install a current Neovim archive on architecture: $machine_"
      return 0
      ;;
  esac

  archive_name_="nvim-linux-$asset_arch_"
  download_url_="https://github.com/neovim/neovim/releases/latest/download/$archive_name_.tar.gz"

  info 'The distribution Neovim is older than 0.11; installing the official release in ~/.local'
  if [ "${DF_DRY_RUN:-0}" -eq 1 ]; then
    printf '    download %s\n' "$download_url_"
    printf '    install into %s and link %s\n' "$install_root_" "$binary_link_"
    return 0
  fi

  (
    local temporary_
    local archive_
    local extracted_

    temporary_="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-nvim.XXXXXX")"
    archive_="$temporary_/nvim.tar.gz"
    extracted_="$temporary_/$archive_name_"
    trap 'rm -rf "${temporary_:?}"' EXIT HUP INT TERM

    curl --fail --location --retry 3 --output "$archive_" "$download_url_"
    tar -xzf "$archive_" -C "$temporary_"
    [ -x "$extracted_/bin/nvim" ] || die 'The downloaded Neovim archive had an unexpected layout.'

    mkdir -p "$install_parent_" "$HOME/.local/bin"
    if [ -e "$install_root_" ] || [ -L "$install_root_" ]; then
      mv "$install_root_" "$install_root_.backup-$timestamp_"
    fi
    mv "$extracted_" "$install_root_"

    if [ -e "$binary_link_" ] || [ -L "$binary_link_" ]; then
      mv "$binary_link_" "$binary_link_.backup-$timestamp_"
    fi
    ln -s "$install_root_/bin/nvim" "$binary_link_"
  )
}

ensure_current_neovim()
{
  if neovim_is_current; then
    success 'Neovim 0.11 or newer is installed'
    return 0
  fi

  if [ "$DF_FAMILY" != 'macos' ]; then
    install_current_neovim_for_linux
  else
    warn 'Neovim 0.11 or newer is required; run brew upgrade neovim if the installed version is older.'
  fi
}

select_packages()
{
  local profile_="$1"
  DF_PACKAGES=()
  DF_CASKS=()

  case "$DF_FAMILY" in
    macos)
      DF_PACKAGES=(
        bash bat btop coreutils curl direnv eza fd fzf gh git git-delta gnupg
        jq lazygit mise neovim ripgrep tmux tree unzip wget yq zoxide
      )
      if [ "$profile_" = 'dev' ] || [ "$profile_" = 'full' ]; then
        DF_PACKAGES+=(ccache cmake gcc llvm ninja node pnpm python shellcheck shfmt uv)
      fi
      if [ "$profile_" = 'full' ]; then
        DF_PACKAGES+=(podman)
        DF_CASKS=(ghostty)
      fi
      ;;
    fedora)
      DF_PACKAGES=(
        bat btop curl direnv eza fd-find fzf gh git git-delta gnupg2 jq
        lazygit neovim ripgrep tmux tree unzip util-linux-user wget wl-clipboard
        xclip yq zoxide zsh
      )
      if [ "$profile_" = 'dev' ] || [ "$profile_" = 'full' ]; then
        DF_PACKAGES+=(
          ccache clang clang-tools-extra cmake gcc gcc-c++ gdb lldb make
          ninja-build nodejs npm pnpm python3 python3-devel python3-pip
          ShellCheck shfmt
        )
      fi
      if [ "$profile_" = 'full' ]; then
        DF_PACKAGES+=(ghostty podman podman-compose)
      fi
      ;;
    arch)
      DF_PACKAGES=(
        bat btop curl direnv eza fd fzf git github-cli git-delta gnupg jq
        lazygit mise neovim ripgrep tmux tree unzip wget wl-clipboard xclip yq
        zoxide zsh
      )
      if [ "$profile_" = 'dev' ] || [ "$profile_" = 'full' ]; then
        DF_PACKAGES+=(
          base-devel ccache clang cmake gdb lldb ninja nodejs npm pnpm python
          python-pip shellcheck shfmt
        )
      fi
      if [ "$profile_" = 'full' ]; then
        DF_PACKAGES+=(ghostty podman podman-compose)
      fi
      ;;
    debian)
      DF_PACKAGES=(
        bat btop curl direnv eza fd-find fzf gh git git-delta gnupg jq lazygit
        neovim ripgrep tmux tree unzip wget wl-clipboard xclip yq zoxide zsh
      )
      if [ "$profile_" = 'dev' ] || [ "$profile_" = 'full' ]; then
        DF_PACKAGES+=(
          build-essential ccache clang clangd cmake gdb lldb ninja-build
          nodejs npm pnpm python3 python3-dev python3-pip python3-venv
          shellcheck shfmt
        )
      fi
      if [ "$profile_" = 'full' ]; then
        DF_PACKAGES+=(podman podman-compose)
      fi
      ;;
  esac
}

install_packages()
{
  local profile_="$1"

  if [ "$DF_PACKAGE_MANAGER" = 'brew' ]; then
    ensure_homebrew
  elif ! command_exists "$DF_PACKAGE_MANAGER"; then
    if [ "${DF_DRY_RUN:-0}" -eq 1 ]; then
      warn "Package manager is unavailable in this dry-run environment: $DF_PACKAGE_MANAGER"
    else
      die "Required package manager is unavailable: $DF_PACKAGE_MANAGER"
    fi
  fi

  select_packages "$profile_"

  if [ "$DF_PACKAGE_MANAGER" = 'apt' ]; then
    info 'Refreshing APT package metadata'
    run_as_root apt-get update
  fi

  filter_available_packages "${DF_PACKAGES[@]}"

  if [ "${#DF_AVAILABLE_PACKAGES[@]}" -gt 0 ]; then
    info "Installing ${#DF_AVAILABLE_PACKAGES[@]} command-line packages"
    case "$DF_PACKAGE_MANAGER" in
      brew)
        run brew install "${DF_AVAILABLE_PACKAGES[@]}"
        ;;
      dnf)
        run_as_root dnf install -y --skip-unavailable "${DF_AVAILABLE_PACKAGES[@]}"
        ;;
      pacman)
        run_as_root pacman -S --needed --noconfirm "${DF_AVAILABLE_PACKAGES[@]}"
        ;;
      apt)
        run_as_root apt-get install -y "${DF_AVAILABLE_PACKAGES[@]}"
        ;;
    esac
  fi

  if [ "${#DF_CASKS[@]}" -gt 0 ]; then
    info "Installing ${#DF_CASKS[@]} desktop packages"
    run brew install --cask "${DF_CASKS[@]}"
  fi

  ensure_current_neovim
}

