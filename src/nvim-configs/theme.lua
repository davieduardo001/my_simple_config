return {
	-- Install Gruvbox
	{ "shaunsingh/nord.nvim", priority = 1000 },

	-- Configure LazyVim to use it
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "nord",
		},
	},
}
