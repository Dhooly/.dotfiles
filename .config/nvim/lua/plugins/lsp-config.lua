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

    if #vim.api.nvim_list_uis() > 0 then
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pyright', 'ts_ls' },
        -- Servers are configured explicitly below. Disabling automatic
        -- enablement also keeps this usable during a Neovim 0.10 transition.
        automatic_enable = false,
      })
    end

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
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if has_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Prefer ccls when it is already installed, including Daniel's source
    -- build, and fall back to the more widely packaged clangd.
    local lspconfig = require("lspconfig")
    local local_ccls = vim.fn.expand('~/bin/ccls/Release/ccls')
    local ccls = vim.fn.executable(local_ccls) == 1 and local_ccls or vim.fn.exepath('ccls')

    if ccls ~= '' then
      lspconfig.ccls.setup({
        capabilities = capabilities,
        cmd = { ccls },
        init_options = {
          cache = {
            directory = ".ccls-cache"
          },
          highlight = { lsRanges = true },
          compilationDatabaseDirectory = "build",
        }
      })
    else
      lspconfig.clangd.setup({
        capabilities = capabilities,
      })
    end

    for _, server in ipairs({ 'lua_ls', 'pyright', 'ts_ls' }) do
      lspconfig[server].setup({
        capabilities = capabilities,
      })
    end

    -- Minimal diagnostics setup, if needed
    vim.diagnostic.config({
      virtual_text = false, -- Disable inline text
      signs = false,         -- Show signs in the gutter
      underline = false,     -- Underline issues in the buffer
      update_in_insert = false, -- Do not update diagnostics while typing
    })
  end,
}
