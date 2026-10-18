
---------------------------------------------------------
-- Floating Terminal
-- Neovim 0.11+ | Windows / Linux
---------------------------------------------------------

local M = {}

local ICON = {
  terminal = "  ",
  lazygit = " 󰊢 ",
}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, {
    title = "Floating Terminal",
  })
end

---------------------------------------------------------
-- Shell
---------------------------------------------------------

local function wrap_command(cmd)
  if vim.fn.has("win32") == 1 then
    local shell = vim.fn.exepath("pwsh") ~= ""
    and "pwsh"
    or "powershell"

    return {
      shell,
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      cmd,
    }
  end

  return { "bash", "-lc", cmd }
end

---------------------------------------------------------
-- Floating terminal
---------------------------------------------------------

function M.open(cmd, opts)
  opts = opts or {}

  local width = math.max(
    1,
    math.floor(vim.o.columns * (opts.width or 0.80))
  )

  local height = math.max(
    1,
    math.floor(vim.o.lines * (opts.height or 0.80))
  )

  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2 - 1)),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    border = opts.border or (vim.g.transparency and "rounded" or "solid"),
    title = opts.title or (ICON.terminal .. "Terminal "),
    title_pos = "center",
    style = "minimal",
  })

  vim.wo[win].winhighlight = table.concat({
    "NormalFloat:NormalFloat",
    "FloatBorder:FloatBorder",
    "FloatTitle:FloatTitle",
  }, ",")

  vim.bo[buf].bufhidden = "wipe"

  local closed = false

  local function close()
    if closed then
      return
    end

    closed = true

    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end

    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  vim.keymap.set("n", "q", close, {
    buffer = buf,
    silent = true,
    nowait = true,
    desc = "Close floating terminal",
  })

  vim.keymap.set("t", "<C-q>", function()
    vim.api.nvim_chan_send(vim.bo[buf].channel, "\003")
    close()
  end, {
  buffer = buf,
  silent = true,
  desc = "Close floating terminal",
})

local ok, job = pcall(vim.fn.jobstart, wrap_command(cmd), {
  term = true,
  on_exit = function(_, code)
    vim.schedule(function()
      if code ~= 0 then
        notify(
          "El proceso terminó con código " .. code,
          vim.log.levels.WARN
        )
      end

      if opts.close_on_exit ~= false then
        close()
      end
    end)
  end,
})

if not ok or job <= 0 then
  close()
  notify("No se pudo iniciar el comando", vim.log.levels.ERROR)
  return
end

vim.cmd("startinsert")

return {
  buf = buf,
  win = win,
  close = close,
  job = job,
}
end

---------------------------------------------------------
-- LazyGit
---------------------------------------------------------

function M.lazygit_toggle()
  if vim.fn.executable("lazygit") == 0 then
    notify("LazyGit no está instalado o no está en PATH", vim.log.levels.ERROR)
    return
  end

  return M.open("lazygit", {
    title = ICON.lazygit .. "LazyGit ",
    width = 0.90,
    height = 0.85,
    close_on_exit = true,
  })
end

return M
