local M = {}

local function scheme_to_bg(u32)
  if u32 == 1 then
    return "dark"
  end
  if u32 == 2 then
    return "light"
  end
  return nil
end

local function apply(bg)
  if not bg then
    return
  end
  if vim.o.background == bg and vim.g.colors_name == "solarized" then
    return
  end
  vim.o.termguicolors = true
  vim.o.background = bg
  vim.cmd.colorscheme("solarized")
end

function M.setup()
  -- 启动先读一次
  do
    local out = vim.fn.system({
      "gdbus",
      "call",
      "--session",
      "--dest",
      "org.freedesktop.portal.Desktop",
      "--object-path",
      "/org/freedesktop/portal/desktop",
      "--method",
      "org.freedesktop.portal.Settings.Read",
      "org.freedesktop.appearance",
      "color-scheme",
    })
    local n = tonumber(out:match("uint32%s*(%d+)"))
    apply(scheme_to_bg(n))
  end

  -- 实时监听
  local job = vim.fn.jobstart({
    "gdbus",
    "monitor",
    "--session",
    "--dest",
    "org.freedesktop.portal.Desktop",
    "--object-path",
    "/org/freedesktop/portal/desktop",
  }, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      if not data then
        return
      end
      for _, line in ipairs(data) do
        if line:find("org%.freedesktop%.appearance") and line:find("color%-scheme") and line:find("SettingChanged") then
          local n = tonumber(line:match("<uint32%s+(%d+)>"))
          apply(scheme_to_bg(n))
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if job and job > 0 then
        pcall(vim.fn.jobstop, job)
      end
    end,
  })
end

return M
