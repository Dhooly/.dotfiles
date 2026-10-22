# Neovim configuration audit

This audit is intentionally conservative. The current configuration is treated
as user work: definite portability problems are fixed, while uncertain plugins
remain available until normal use shows whether they are valuable.

## Active and useful

- `lazy.nvim`: plugin manager and lockfile support
- Gruvbox: colorscheme shared with the terminal and tmux palette
- Bufferline: visible buffer navigation and reordering
- Telescope: files, grep, buffers, help, and LSP navigation
- Treesitter and Treesitter Context: parsing and optional context display
- Gitsigns: hunk navigation, previews, blame, and diffs
- Harpoon: a small working set of frequently visited files
- Comment and Autopairs: editing helpers
- `nvim-lspconfig`, Mason, and `nvim-cmp`: C/C++, Python, Lua, JavaScript, and
  TypeScript language integration and completion
- `vim-tmux-navigator`: consistent pane and window movement
- Noice and NUI: command-line and notification presentation
- Todo Comments: TODO/FIXME discovery
- Indent Blankline: indentation guides

## Present but disabled

These plugin specifications return no active plugin or have their implementation
commented out. They cost effectively nothing at runtime and can be removed after
confirming they are no longer wanted:

- `illuminate.lua`
- `neo-tree.lua`
- `smear_cursor.lua`
- `symbols-outline.lua`
- `vim-log-highlighting.lua`

## Changes made during the portability pass

- Replaced the hard-coded `/home/daniel/bin` PATH entry with `~/bin`
- Preserved the local `~/bin/ccls/Release/ccls` preference, then fall back to a
  system `ccls` or `clangd`
- Defined the previously missing LSP completion capabilities
- Added a minimal LSP completion UI using Neovim's built-in snippet support
- Replaced Linux-only `nproc` use with CMake's portable `--parallel` option
- Shell-escaped the build directory before sending it to a terminal
- Kept `<leader>st` for LSP type definitions and moved TODO searches to
  `<leader>sc`/`<leader>sC`, removing a load-order-dependent keymap collision

## Follow-up candidates

- Decide whether LSP-only completion should gain buffer and path sources
- Remove disabled plugin files after a few weeks of normal use
- Split the large `init.lua` into options, keymaps, autocmds, and build helpers
  once behavior is stable

