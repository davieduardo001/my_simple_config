return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			-- "night" is the darkest default style
			style = "night",
			transparent = false, -- We want a solid black background, not transparent
			styles = {
				sidebars = "transparent", -- Make sidebars (NvimTree) blend in
				floats = "transparent", -- Make floating windows blend in
			},
			on_colors = function(colors)
				-- FORCE PURE BLACK
				colors.bg = "#000000"
				colors.bg_dark = "#000000"
				colors.bg_float = "#000000"
				colors.bg_sidebar = "#000000"
				colors.bg_popup = "#000000"
			end,
			on_highlights = function(hl, c)
				-- Ensure the main window is pitch black
				hl.Normal = { bg = "#000000", fg = c.fg }
				hl.NormalNC = { bg = "#000000", fg = c.fg }
				hl.NormalFloat = { bg = "#000000", fg = c.fg }
				hl.WinSeparator = { fg = "#444444", bold = true } -- Make splits visible
			end,
		},
	},

	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight",
		},
	},
}
