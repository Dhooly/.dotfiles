return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    indent = { char = "│" }, -- Character for indentation guides
    scope = {
      enabled = false,
      show_start = false, -- Disable underline at the start of the scope
      show_end = false,   -- Disable underline at the end of the scope
    },
    exclude = {
      filetypes = { "help", "startify", "dashboard", "lazy" }, -- Excluded file types
      buftypes = { "terminal", "nofile" }, -- Excluded buffer types
    },
  }
}
