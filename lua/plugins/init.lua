return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- mini.icons is configured by NvChad's spec (nvim-mini/mini.icons)

  {
    "rosasrias/code-runner.nvim",
    opts = {
      terminal = { direction = "horizontal" },
      autoclose = false,
    },
    keys = {
      { "<C-b>", "<cmd>CodeRun<CR>", mode = { "n", "i" }, desc = "code-runner: run" },
      { "<leader>rl", "<cmd>CodeRunLast<CR>", desc = "code-runner: run last" },
    },
  },

  {
    "rosasrias/DotnetForge",
    cmd = { "DotnetForge", "DotnetNewProject" },
    opts = {},
    keys = {
      { "<leader>dn", "<cmd>DotnetForge<CR>", desc = "dotnetforge: new project" },
    },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
