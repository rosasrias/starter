-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "onedarkpro",
	transparency = true,

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.nvdash = {
  load_on_startup = true,
}

M.ui = {
  cmp = {    style = "atom_colored",
    icons_left = false,
    lspkind_text = true,
    format_colors = { tailwind = true },
  },
  tabufline = {
    lazyload = false,
  },
  statusline = {
    enabled = true,
    theme = "fancy",
    separator_style = "default",
  },
  telescope = { style = "borderless" },
}

M.mason = {
  pkgs = {
    -- LSPs
    "clangd",
    "csharp-language-server",
    "typescript-language-server", -- ts_ls
    "jdtls",
    "intelephense",
    "emmet-language-server",
    "html-lsp",
    "css-lsp",
    "json-lsp",
    "texlab",
    "pyright",
    -- formatters
    "stylua",
  },
}

M.cheatsheet = { theme = "grid" }
M.colorify = { enabled = true, mode = "virtual" }

return M
