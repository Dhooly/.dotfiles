# Daniel's dotfiles

An opinionated, repeatable development environment for macOS and Linux. One
command installs the command-line tools, configures Zsh and Oh My Zsh, and
links the editor and terminal configuration into place.

## Quick start

On a fresh machine, install Git and clone the repository:

```bash
git clone https://github.com/Dhooly/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The installer shows its plan and asks once before making changes. Existing
dotfiles are moved into a timestamped directory under `~/.dotfiles-backup/`;
they are never silently overwritten.

If an existing `~/.gitconfig` is present, it is also copied to the ignored
`~/.gitconfig.local` before linking. This keeps the existing Git identity,
signing, and credential configuration active.

Preview everything without changing the machine:

```bash
./bootstrap.sh --dry-run
```

For an unattended installation:

```bash
./bootstrap.sh --yes
```

## Supported systems

| Support | Systems | Package manager |
| --- | --- | --- |
| First class | macOS, Fedora, CachyOS | Homebrew, DNF, Pacman |
| Regularly tested | Ubuntu, Debian, Arch Linux | APT, Pacman |
| Best effort | Fedora-, Debian-, and Arch-derived distributions | Family package manager |

The bootstrap detects CachyOS directly before falling back to its Arch family.
It uses only official repositories and does not require an AUR helper.

## Profiles

The default `full` profile creates a complete workstation. Smaller profiles are
useful for remote machines and containers.

| Profile | Includes |
| --- | --- |
| `core` | Zsh, Oh My Zsh, Git, Neovim, tmux, and modern CLI tools |
| `dev` | Core plus C/C++, CMake, Ninja, debuggers, Python, Node.js, and shell tooling |
| `full` | Dev plus Ghostty, Monaco for Powerline, a Nerd Font fallback, and Podman where packaged |

Choose a profile with:

```bash
./bootstrap.sh --profile dev
```

Run `./bootstrap.sh --help` for switches that skip package installation, Oh My
Zsh, tmux plugins, or the default-shell change.

## What gets configured

- Zsh with Oh My Zsh, autosuggestions, syntax highlighting, shared history,
  completions, and lightweight cross-platform aliases
- tmux with TPM, sensible defaults, the existing SSH-split and mouse plugins,
  portable clipboard integration, and seamless Neovim pane navigation
- Neovim with the existing Gruvbox, Telescope, Treesitter, Harpoon, Bufferline,
  Git, tmux, and C/C++ workflow
- Ghostty with the One Half Dark Vibrant theme, Monaco for Powerline, and a
  Meslo Nerd Font fallback; plus tmux with true-color support
- Git defaults that favor safe rebases, pruning, `rerere`, and readable diffs
- CLI tools including `ripgrep`, `fd`, `fzf`, `bat`, `eza`, `jq`, `yq`,
  `zoxide`, `direnv`, GitHub CLI, lazygit, and delta when the distribution
  packages them
- C and C++ compilers, CMake, Ninja, ccache, GDB/LLDB, Python, ShellCheck, and
  shfmt in development profiles
- Node.js and pnpm, with JavaScript and TypeScript parsing and LSP support

Package availability differs between distributions. The installer checks each
Linux repository and skips unavailable optional packages with a warning. Run
the doctor afterward to see exactly what is present.

Monaco for Powerline is installed per-user from an immutable revision of the
community-patched font. The source does not publish clear redistribution terms,
so review the source URL in `scripts/lib/packages.sh` before using this setup
outside a personal dotfiles repository.

The Neovim configuration requires Neovim 0.11 or newer. When a Linux
distribution ships an older build, the bootstrap installs Neovim's official
release under `~/.local/opt/nvim` without replacing system files.

## Verify a setup

```bash
~/.dotfiles/scripts/doctor.sh
```

Use the same profile used during installation if it was not `full`:

```bash
~/.dotfiles/scripts/doctor.sh --profile core
```

## Local customization and secrets

Machine-specific settings belong in ignored local files:

- `~/.zshrc.local` for aliases, environment variables, and shell integrations
- `~/.zprofile.local` for login-time PATH changes
- `~/.tmux.conf.local` for machine-specific tmux settings
- `~/.gitconfig.local` for identity, signing, and credential settings

The Ghostty config and repo-managed themes are linked individually. The local
`~/.config/ghostty/themes/` directory remains in place, so additional
machine-specific themes are preserved.

For example:

```ini
# ~/.gitconfig.local
[user]
  name = Daniel
  email = you@example.com
```

Never commit access tokens, SSH private keys, cloud credentials, or employer
configuration to this repository.

## Repository layout

```text
.
├── bootstrap.sh          # One-command entry point
├── bin/                  # Small cross-platform helpers
├── scripts/
│   ├── doctor.sh         # Installation diagnostics
│   └── lib/              # Platform, package, link, and Zsh helpers
├── tests/                # Platform-detection tests
├── .config/
│   ├── ghostty/
│   └── nvim/
├── .zshrc
├── .zprofile
├── .tmux.conf
└── .gitconfig
```

## Development

Run the local checks before committing:

```bash
make check
```

The test suite validates macOS, Fedora, CachyOS, Ubuntu, Debian, and compatible
distribution detection. GitHub Actions also runs shell checks plus macOS and
Fedora dry runs.

## Restoring previous files

When a destination already exists, the bootstrap prints the exact backup path
before moving it. To restore a file, remove its generated symlink and move the
corresponding file out of that timestamped `~/.dotfiles-backup/` directory.

The bootstrap does not delete backups, uninstall packages, or remove Oh My Zsh.

