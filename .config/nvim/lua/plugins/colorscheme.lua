return { 

  -- 'folke/tokyonight.nvim',
  -- priority = 1000, -- Make sure to load this before all the other start plugins.
  -- init = function()
  --   vim.cmd.colorscheme 'tokyonight-moon'
  --
  --   vim.cmd.hi 'Comment gui=none'
  -- end,

	'ellisonleao/gruvbox.nvim',
	priority = 1000,
	init = function()
		vim.cmd.colorscheme 'gruvbox'

		vim.cmd.hi 'Comment gui=none'
	end,
}
