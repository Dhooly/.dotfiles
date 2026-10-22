return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Basic mappings
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon file" })
      vim.keymap.set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

      -- Set 1-4 keys to switch to files directly
      vim.keymap.set("n", "<leader>h", function() harpoon:list():select(1) end, { desc = "Harpoon slot 1" })
      vim.keymap.set("n", "<leader>j", function() harpoon:list():select(2) end, { desc = "Harpoon slot 2" })
      vim.keymap.set("n", "<leader>k", function() harpoon:list():select(3) end, { desc = "Harpoon slot 3" })
      vim.keymap.set("n", "<leader>l", function() harpoon:list():select(4) end, { desc = "Harpoon slot 4" })

      -- Toggle previous & next buffers stored in harpoon list
      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
    end
  }
}

