require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>nd", function()
  require("nvchad.nvdash").open()
end, { desc = "open nvdash" })

map("n", "<leader>th",function ()
  require("nvchad.themes").open()
end,{})

map("n", "<leader>gg", function()
  require("lazygit").lazygit_toggle()
end, {
  desc = "Git: LazyGit",
})
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
