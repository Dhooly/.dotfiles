return {
  'lewis6991/gitsigns.nvim',
  lazy = false,
  init = function()
    require('gitsigns').setup {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      preview_config = {
        border = { '', '', '', ' ' },
      },
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 1000,
        ignore_whitespace = false,
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]c", gs.next_hunk, "Next Hunk")
        map("n", "[c", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghu", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")

        -- Set SignColumn background to match the editor background
        local bg_color = vim.api.nvim_get_hl_by_name("Normal", true).background
        if bg_color then
          vim.api.nvim_set_hl(0, "SignColumn", { bg = string.format("#%06x", bg_color), fg = "NONE" })
        else
          vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE", fg = "NONE" })
        end
      end,
    }
  end,
}
