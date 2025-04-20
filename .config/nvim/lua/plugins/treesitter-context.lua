return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "BufReadPost",
  config = function()
    local ts_context = require("treesitter-context")
    ts_context.setup {
      enable = false,  -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 10,  -- Increase context window span for large files
      trim_scope = "inner",  -- Keep more relevant nested scopes
      min_window_height = 15, -- Adjust for larger files with deep nesting
      line_numbers = true,  -- Show line numbers
      multiline_threshold = 50,  -- Allow deeper nesting before truncation
      mode = "topline",  -- "cursor" for context under cursor, "topline" for topmost line
      -- separator = "─",  -- Visually separate context for clarity
      zindex = 20,  -- The Z-index of the context window
    }

    -- Toggle function
    vim.api.nvim_create_user_command("ToggleContext", function()
      ts_context.toggle()
    end, { desc = "Toggle Treesitter Context" })

    -- Keybinding to toggle Treesitter Context
    vim.keymap.set("n", "<leader>tc", ":ToggleContext<CR>", { noremap = true, silent = true, desc = "Toggle Treesitter Context" })
  end,
}
