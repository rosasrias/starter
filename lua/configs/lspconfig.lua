require("nvchad.configs.lspconfig").defaults()

local servers = {
  -- Web
  "html",
  "cssls",
  "emmet_ls",
  "ts_ls",       -- JavaScript / JSX / TS / TSX
  "jsonls",

  -- Sistemas / nativo
  "clangd",      -- C / C++
  "csharp_ls",   -- C#

  -- Scripting / backend
  "pyright",     -- Python
  "intelephense",-- PHP (blade incluido)
  "texlab",      -- LaTeX
  "jdtls",       -- Java
}

-- blade: se atiende con intelephense + emmet_ls
vim.lsp.enable(servers)

-- detectar *.blade.php como filetype "blade"
vim.filetype.add({
  pattern = { [".*%.blade%.php"] = "blade" },
})

-- emmet_ls también en archivos blade y php dentro de blade
vim.lsp.config("emmet_ls", {
  filetypes = {
    "html", "css", "scss", "less",
    "javascriptreact", "typescriptreact",
    "vue", "svelte", "astro",
    "php", "blade",
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
