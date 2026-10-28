return {
  {
    dir = "C:/Users/rosas/Documents/code/plugins/Katana.nvim",
    name = "katana.nvim",
    event = "LspAttach",
    dependencies = { "nvim-mini/mini.icons" },
    config = function()
      local katana = require("katana")
      katana.setup({})

      vim.keymap.set({ "n", "v" }, "<leader>ca", function()
        katana.code_action()
      end, { desc = "Katana: Code Actions" })

      vim.keymap.set({ "n", "v" }, "<leader>cA", function()
        katana.source_action()
      end, { desc = "Katana: Source Actions" })
    end,
  },
}
