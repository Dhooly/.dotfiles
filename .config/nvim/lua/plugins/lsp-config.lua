return {
  'neovim/nvim-lspconfig',  -- LSP configuration plugin
  dependencies = {
    'williamboman/mason.nvim',  -- Mason for managing LSP servers and tools
    'williamboman/mason-lspconfig.nvim',  -- Mason integration for lspconfig
    'hrsh7th/cmp-nvim-lsp',  -- LSP completion source for nvim-cmp
  },
  config = function()
    -- Setup mason
    require('mason').setup()

    -- Setup mason-lspconfig to ensure clangd is installed
    -- require('mason-lspconfig').setup({
    --   ensure_installed = { 'clangd' },  -- Ensure clangd is installed via mason
    -- })

    -- LSP configuration for clangd
    -- local lspconfig = require('lspconfig')
    -- lspconfig.clangd.setup({
    --   on_attach = function(_, bufnr)
    --     -- Helper function to set keymaps for LSP features
    --     local bufmap = function(mode, lhs, rhs, desc)
    --       vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    --     end
    --
    --     -- Keybinding to go to definition
    --     bufmap('n', 'gr', vim.lsp.buf.references, "Find references")
    --     bufmap('n', 'K', vim.lsp.buf.hover, "Hover documentation")
    --     bufmap('n', 'gi', vim.lsp.buf.implementation, "Go to implementation")
    --     bufmap('n', 'gh', vim.lsp.buf.signature_help, "Signature help")
    --     bufmap('n', 'gD', vim.lsp.buf.type_definition, "Go to type definition")
    --   end,
    --   capabilities = require('cmp_nvim_lsp').default_capabilities(),  -- Enable LSP completion
    -- })
      -- Manually configure ccls (not supported by Mason)
    local lspconfig = require("lspconfig")
    lspconfig.ccls.setup({
      capabilities = capabilities,
      init_options = {
        cache = {
          directory = ".ccls-cache"
        },
        highlight = { lsRanges = true },
        compilationDatabaseDirectory = "build",
      }
    })

    -- Minimal diagnostics setup, if needed
    vim.diagnostic.config({
      virtual_text = false, -- Disable inline text
      signs = false,         -- Show signs in the gutter
      underline = false,     -- Underline issues in the buffer
      update_in_insert = false, -- Do not update diagnostics while typing
    })
  end,
}
