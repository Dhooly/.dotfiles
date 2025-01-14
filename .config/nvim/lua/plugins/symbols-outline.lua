return {
	'simrat39/symbols-outline.nvim',
	cmd = "SymbolsOutline",
	config = function()
		require('symbols-outline').setup()
	end,
	keys = { { "<F8>", "<cmd>SymbolsOutline<CR>", desc = "Toggle Symbols Outline" } },
}
