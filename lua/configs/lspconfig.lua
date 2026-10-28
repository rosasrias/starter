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
  "roslyn_ls",   -- C# (Roslyn oficial)

  -- Scripting / backend
  "pyright",     -- Python
  "intelephense",-- PHP (blade incluido)
  "texlab",      -- LaTeX
  "jdtls",       -- Java
}

--------------------------------------------------------------------------------
-- Roslyn (C#)
--
-- `csharp_ls` (csharp-language-server) es un servidor limitado: no implementa
-- las code actions de Roslyn, así que acciones como "Generar método Suma" (la
-- que ofrece Visual Studio al llamar a un método inexistente) no aparecen.
-- `roslyn_ls` es el servidor oficial de Microsoft y sí las trae.
--
-- El binario (`roslyn-language-server`) lo instala Mason y se lanza siempre
-- con `--stdio`. Necesita el .NET SDK en el PATH.
--------------------------------------------------------------------------------
vim.lsp.config("roslyn_ls", {
  cmd = { "roslyn-language-server", "--stdio" },
  filetypes = { "cs" },

  -- Primero la solución (.sln/.slnx) y, si no hay, el proyecto (.csproj).
  -- Como último recurso se usa la carpeta del propio fichero, para que un
  -- .cs suelto siga teniendo LSP (sin proyecto no habrá diagnósticos de
  -- compilación, pero sí los de análisis).
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then
      return
    end

    local dir = vim.fs.dirname(fname)

    local sln = vim.fs.root(dir, function(name)
      return name:match("%.sln[x]?$") ~= nil
    end)
    if sln then
      return on_dir(sln)
    end

    local csproj = vim.fs.root(dir, function(name)
      return name:match("%.csproj$") ~= nil
    end)
    if csproj then
      return on_dir(csproj)
    end

    on_dir(dir)
  end,
})

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

------------------------------------------------------------------------------
-- Ruido de Roslyn al abrir un proyecto C#. Ninguno de los dos avisos indica
-- un error real, así que se silencian en su origen (sin tocar `vim.notify`,
-- que es de noice.nvim, para no disparar su warning de "overwritten"):
--
--   * "Roslyn project initialization complete"
--       handler `workspace/projectInitializationComplete` de nvim-lspconfig.
--       Se reimplementa sin `vim.notify` pero conservando el refresco de
--       diagnósticos, que es el motivo por el que existe ese handler.
--
--   * "watch.watch: ENOENT: no such file or directory"
--       Roslyn registra un watcher (`workspace/didChangeWatchedFiles`) sobre
--       C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework, que
--       no existe si no hay .NET Framework reference assemblies instalados.
--       vim/_watch.lua avisa con vim.notify_once, así que se evita llamando a
--       `fs_event_start` sobre directorios que no existen (no-op silencioso).
------------------------------------------------------------------------------
local function refresh_roslyn_diagnostics(client)
  local capabilities = vim
    .iter(client.dynamic_capabilities.capabilities.diagnosticProvider or {})
    :map(function(cap)
      return cap.registerOptions.identifier
    end)
    :totable()

  for buf in pairs(client.attached_buffers) do
    if vim.api.nvim_buf_is_loaded(buf) then
      for _, identifier in pairs(capabilities) do
        client:request(vim.lsp.protocol.Methods.textDocument_diagnostic, {
          identifier = identifier,
          textDocument = vim.lsp.util.make_text_document_params(buf),
        }, nil, buf)
      end
    end
  end
end

vim.lsp.config("roslyn_ls", {
  handlers = {
    ["workspace/projectInitializationComplete"] = function(_, _, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if client then
        refresh_roslyn_diagnostics(client)
      end
      return vim.NIL
    end,
  },
})

-- Ignora silenciosamente los watchers cuyo directorio base no existe.
local ok, watchfiles = pcall(require, "vim.lsp._watchfiles")
if ok and type(watchfiles._watchfunc) == "function" then
  local watch_func = watchfiles._watchfunc

  watchfiles._watchfunc = function(base_dir, opts, callback)
    if vim.uv.fs_stat(base_dir) == nil then
      return function() end
    end
    return watch_func(base_dir, opts, callback)
  end
end

-- read :h vim.lsp.config for changing options of lsp servers
