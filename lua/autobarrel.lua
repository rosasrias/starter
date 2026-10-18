local M = {}

local uv = vim.loop

-- Directorios ignorados
local ignored_dirs = {
  node_modules = true,
  dist = true,
  build = true,
  coverage = true,
  [".git"] = true,
}

-- Archivos ignorados
local ignored_files = {
  ["index.js"] = true,
}

-- Extensiones válidas
local valid_extensions = {
  js = true,
  jsx = true,
  ts = true,
  tsx = true,
}

-- Normaliza paths Windows/Linux/Mac
local function normalize_path(path)
  return path:gsub("\\", "/")
end

-- Verifica extensión válida
local function is_valid_file(file)
  local ext = file:match "^.+%.(.+)$"

  if not ext then
    return false
  end

  return valid_extensions[ext]
end

-- Ignorar archivos especiales
local function should_ignore_file(name)
  if ignored_files[name] then
    return true
  end

  if name:match "%.test%." then
    return true
  end

  if name:match "%.spec%." then
    return true
  end

  if name:match "%.stories%." then
    return true
  end

  if name == "vite.config.js" or name == "webpack.config.js" or name == "jest.config.js" then
    return true
  end

  return false
end

-- Detecta export default
local function file_has_default_export(path)
  local ok, lines = pcall(vim.fn.readfile, path)

  if not ok then
    return false
  end

  local content = table.concat(lines, "\n")

  return content:match "export%s+default" ~= nil
end

-- Escaneo recursivo
local function scan_dir(dir, root, exports)
  local handle = uv.fs_scandir(dir)

  if not handle then
    return
  end

  while true do
    local name, type = uv.fs_scandir_next(handle)

    if not name then
      break
    end

    local full_path = normalize_path(dir .. "/" .. name)

    -- Directorios
    if type == "directory" then
      if not ignored_dirs[name] then
        scan_dir(full_path, root, exports)
      end

      -- Archivos
    elseif type == "file" then
      if not should_ignore_file(name) and is_valid_file(name) then
        local relative = full_path:gsub("^" .. vim.pesc(root) .. "/", ""):gsub("%.jsx?$", ""):gsub("%.tsx?$", "")

        -- Si tiene default export
        if file_has_default_export(full_path) then
          local component_name = relative:match "([^/]+)$"

          table.insert(exports, string.format("export { default as %s } from './%s'", component_name, relative))

          -- Named exports
        else
          table.insert(exports, string.format("export * from './%s'", relative))
        end
      end
    end
  end
end

function M.generate()
  -- Root proyecto
  local project_root = normalize_path(vim.fn.getcwd())

  -- src root
  local src_root = project_root .. "/src"

  -- index.js final
  local index_file = src_root .. "/index.js"

  local exports = {}

  -- Escaneo
  scan_dir(src_root, src_root, exports)

  -- Ordenar
  table.sort(exports)

  -- Escribir
  vim.fn.writefile(exports, index_file)

  print "src/index.js generado correctamente"
end

return M
