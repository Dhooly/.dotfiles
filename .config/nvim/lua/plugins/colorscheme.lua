return {
  'ellisonleao/gruvbox.nvim',
  lazy = false,    -- Force it to load immediately on startup
  priority = 1000, -- Ensure it loads before all other plugins
  config = function()
    -- Enable truecolor support so Gruvbox colors render perfectly
    vim.opt.termguicolors = true

    -- Load the colorscheme here inside config
    vim.cmd.colorscheme 'gruvbox'

    -- Your custom visual overrides
    vim.cmd.hi 'Comment gui=none'
    vim.cmd.hi 'String gui=none'
  end,
}
