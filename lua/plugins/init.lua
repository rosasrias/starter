return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    -- NvChad lo carga con `event = "User FilePost"`. Eso hace que el primer
    -- fichero abierto en la sesión se quede SIN LSP: `vim.lsp.enable()`
    -- registra su autocmd de FileType cuando el buffer ya tiene el filetype
    -- puesto, así que ese buffer no arranca ningún servidor.
    -- Cargándolo al inicio, todos los buffers encuentran su LSP.
    lazy = false,
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- mini.icons is configured by NvChad's spec (nvim-mini/mini.icons)

  {
    "rosasrias/Ignition.nvim",
    opts = {
      terminal = { direction = "horizontal" },
      autoclose = false,
    },
    keys = {
      { "<C-b>", "<cmd>IgnitionRun<CR>", mode = { "n", "i" }, desc = "Ignition: run" },
      { "<leader>rl", "<cmd>IgnitionRunLast<CR>", desc = "Ignition: run last" },
    },
  },

  {
    "rosasrias/Kiln.nvim",
    cmd = {
      "KilnProject",
      "KilnNew",
      "KilnNewNamespace",
      "KilnNewPackage",
      "KilnDelete",
      "KilnInfo",
    },
    opts = {},
    keys = {
      { "<leader>dn", "<cmd>KilnProject<CR>", desc = "kiln: new project" },
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
