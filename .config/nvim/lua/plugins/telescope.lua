return {
  -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'hrsh7th/nvim-cmp',
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
        -- Set layout configuration to have the search appear at the top
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top", -- This sets the search bar to be at the top
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

        -- List LSP symbols
    -- vim.keymap.set("n", "<leader>pl", ":Telescope lsp_document_symbols<CR>", { desc = "List LSP symbols in file" })
    -- vim.keymap.set("n", "<leader>pL", ":Telescope lsp_workspace_symbols<CR>", { desc = "List LSP symbols in workspace" })

    -- Incoming and Outgoing calls
    vim.keymap.set("n", "<leader>si", function()
      require('telescope.builtin').lsp_incoming_calls()
    end, { desc = "Show incoming calls (who calls this function)" })
    vim.keymap.set("n", "<leader>so", function()
      require('telescope.builtin').lsp_outgoing_calls()
    end, { desc = "Show outgoing calls (functions this calls)" })

    -- Jump to definitions
    vim.keymap.set("n", "<leader>sd", function()
      vim.lsp.buf.definition()
    end, { desc = "Jump to function definition" })
    vim.keymap.set("n", "<leader>sft", function()
      vim.lsp.buf.type_definition()
    end, { desc = "Jump to type definition" })

    vim.keymap.set("n", "<leader>sr", function()
      require('telescope.builtin').lsp_references()
    end, { desc = "Show function references" })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- Shortcut for searching files from home
    vim.keymap.set('n', '<leader>sa', function()
      builtin.find_files { cwd = vim.env.HOME }
    end, { desc = '[S]earch [A]ll files' })
  end,
}
