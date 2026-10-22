return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  -- Wait until the core UI and colorscheme load before rendering the top bar
  event = "VeryLazy", 
  config = function()
    -- Ensure 24-bit color support is on for accuracy
    vim.opt.termguicolors = true
    
    require("bufferline").setup({
      options = {
        always_show_bufferline = true, -- Keep visible even with 1 file open
        separator_style = "thin",       -- Use clean, subtle vertical lines
        show_buffer_close_icons = false, -- Clean up space by hiding tab 'x' buttons
        show_close_icon = false,
      },
      highlights = {
        -- 1. THE FILL (The empty background space behind all tabs)
        fill = {
          bg = '#1d2021', -- Match Gruvbox hard dark background
        },

        -- 2. ACTIVE TAB (Fixes the harsh tan block from your image)
        buffer_selected = {
          fg = '#fbf1c7', -- Clean Gruvbox light cream text
          bg = '#3c3836', -- Soft dark gray (matches active statusline)
          bold = true,
          italic = false,
        },

        -- 3. INACTIVE TABS (The background tabs)
        background = {
          fg = '#a89984', -- Muted gray text for unselected files
          bg = '#282828', -- Medium dark background
        },

        -- 4. SEPARATORS (The vertical dividing lines between tabs)
        separator = {
          fg = '#1d2021', -- Blend into the background
          bg = '#282828',
        },
        separator_selected = {          fg = '#1d2021',
          bg = '#3c3836',
        },
      }
    })
  end
}
