return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000,
  init = function()
    vim.cmd.colorscheme 'gruvbox'

    vim.cmd.hi 'Comment gui=none'
    vim.cmd.hi 'String gui=none'
  end,
}
