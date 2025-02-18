-- vim.opt.rtp:append(vim.fn.stdpath "config" .. ",/home/daniel/.local/share/nvim/nvim/runtime")

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true

vim.opt.undofile = true

-- -- Enable auto-indentation
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cindent = true
--
-- -- Tab and space settings for consistent alignment
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.inccommand = 'split'

vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<CR>', '<cmd>nohlsearch<CR>')

-- Now define key mappings that use <leader>
vim.keymap.set('n', '<leader>hc', ':e %:p:s,.hpp,.cpp,<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>hs', ':e %:p:s,.cpp,.hpp,<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Set .test files to be treated as Python files
vim.cmd [[
  augroup FileTypeTestFiles
    autocmd!
    autocmd BufRead,BufNewFile *.test set filetype=python
    autocmd BufRead,BufNewFile *.stage set filetype=python
  augroup END
]]

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Add plugins to ~/.config/nvim/lua/plugins/<name>.lua
require('lazy').setup({
  { import = 'plugins' },
})
