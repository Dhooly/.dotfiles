#!/usr/bin/env bash

detect_platform()
{
  local kernel_=''
  local os_release_file_="${DOTFILES_OS_RELEASE_FILE:-/etc/os-release}"
  local distro_id=''
  local distro_like=''

  DF_OS=''
  DF_FAMILY=''
  DF_PACKAGE_MANAGER=''

  kernel_="${DOTFILES_UNAME_OVERRIDE:-$(uname -s)}"

  case "$kernel_" in
    Darwin)
      DF_OS='macos'
      DF_FAMILY='macos'
      DF_PACKAGE_MANAGER='brew'
      ;;
    Linux)
      if [ ! -r "$os_release_file_" ]; then
        die "Cannot identify this Linux distribution: $os_release_file_ is missing."
      fi

      # os-release is supplied by the operating system and contains shell-style
      # key/value pairs. The override exists solely for the platform tests.
      # shellcheck disable=SC1090
      . "$os_release_file_"
      distro_id="${ID:-unknown}"
      distro_like="${ID_LIKE:-}"
      DF_OS="$distro_id"

      case "$distro_id" in
        cachyos|arch|endeavouros|manjaro)
          DF_FAMILY='arch'
          DF_PACKAGE_MANAGER='pacman'
          ;;
        fedora|rhel|centos|rocky|almalinux)
          DF_FAMILY='fedora'
          DF_PACKAGE_MANAGER='dnf'
          ;;
        ubuntu|debian|linuxmint|pop|elementary|zorin)
          DF_FAMILY='debian'
          DF_PACKAGE_MANAGER='apt'
          ;;
        *)
          case " $distro_like " in
            *' arch '*)
              DF_FAMILY='arch'
              DF_PACKAGE_MANAGER='pacman'
              ;;
            *' fedora '*|*' rhel '*)
              DF_FAMILY='fedora'
              DF_PACKAGE_MANAGER='dnf'
              ;;
            *' debian '*|*' ubuntu '*)
              DF_FAMILY='debian'
              DF_PACKAGE_MANAGER='apt'
              ;;
            *)
              die "Unsupported Linux distribution: $distro_id (ID_LIKE=$distro_like)"
              ;;
          esac
          ;;
      esac
      ;;
    *)
      die "Unsupported operating system: $kernel_"
      ;;
  esac

  export DF_OS DF_FAMILY DF_PACKAGE_MANAGER
}

platform_summary()
{
  printf 'Operating system : %s\n' "$DF_OS"
  printf 'Platform family  : %s\n' "$DF_FAMILY"
  printf 'Package manager  : %s\n' "$DF_PACKAGE_MANAGER"
}

