return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  requires = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- for file icons
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- Set up Neo-tree
    require("neo-tree").setup({
      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false, -- `false` closes auto-expanded dirs, such as with `:Neotree reveal`
        },
        enable_git_status = true,
        filtered_items = {
          always_show_by_pattern = {
            "*.log",
          },
        },
      },
      window = {
        mappings = {
          ["<CR>"] = "open",          -- Open file in the current window
          ["v"] = "open_vsplit",      -- Open file in vertical split
          ["s"] = "open_split",       -- Open file in horizontal split
          ["t"] = "open_tabnew",         -- Open file in a new tab
          ["q"] = "close_window",     -- Close Neo-tree
          ["h"] = "navigate_up",      -- Collapse directory or go to parent
          ["l"] = "open",             -- Expand directory or open file
          ["a"] = "add",              -- Add a new file or directory
          ["r"] = "rename",           -- Rename the selected file or directory
          ["d"] = "delete",           -- Delete the selected file or directory
          ["y"] = "copy_to_clipboard",-- Copy the selected file to clipboard
          ["p"] = "paste_from_clipboard", -- Paste the clipboard content
          ["c"] = "copy",             -- Copy file or directory
          ["m"] = "move",             -- Move file or directory
        },
      },
    })

    -- Add keybinding to toggle Neo-tree
    vim.api.nvim_set_keymap(
      "n", -- Normal mode
      "<leader>e", -- Keybind: <leader>e
      ":Neotree toggle<CR>", -- Command to toggle Neo-tree
      { noremap = true, silent = true } -- Non-recursive and silent
    )
  end,
}
