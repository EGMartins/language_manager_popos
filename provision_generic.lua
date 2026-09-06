-- provision_generic.lua — instala parsers do Treesitter + pacotes do Mason numa
-- config de Neovim baseada em lazy.nvim que NÃO é o LazyVim (AstroNvim, NvChad,
-- kickstart…). Roda via:
--   NVIM_APPNAME=<app> nvim --headless -c "luafile provision_generic.lua"
--
-- Env:
--   DEVLANG_TS="typescript tsx"          parsers a instalar
--   DEVLANG_MASON="vtsls prettier"       pacotes Mason a instalar
--   DEVLANG_PRUNE_TS / DEVLANG_PRUNE_MASON  itens a remover (uninstall)

local function log(m) io.stderr:write("    [provision] " .. tostring(m) .. "\n") end
local function split(s) return vim.split(s or "", "%s+", { trimempty = true }) end
local function load(p) pcall(function() require("lazy").load({ plugins = p }) end) end

pcall(function() require("lazy").sync({ wait = true, show = false }) end)

load({ "mason.nvim" })
vim.wait(1500)
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. (vim.env.PATH or "")

-- ---- Treesitter --------------------------------------------------------
local ts_add    = split(vim.env.DEVLANG_TS)
local ts_remove = split(vim.env.DEVLANG_PRUNE_TS)
if #ts_add > 0 or #ts_remove > 0 then
  load({ "nvim-treesitter" })
  vim.wait(500)
  local ok, nti = pcall(require, "nvim-treesitter")
  if ok then
    if #ts_add > 0 then
      log("treesitter +: " .. table.concat(ts_add, " "))
      pcall(function()
        local t = nti.install(ts_add)
        if type(t) == "table" and t.wait then t:wait(600000) end
      end)
    end
    if #ts_remove > 0 then
      log("treesitter -: " .. table.concat(ts_remove, " "))
      pcall(function()
        local t = nti.uninstall(ts_remove)
        if type(t) == "table" and t.wait then t:wait(120000) end
      end)
    end
  else
    -- API antiga (branch master): comandos síncronos
    for _, p in ipairs(ts_add) do pcall(vim.cmd, "TSInstallSync " .. p) end
    for _, p in ipairs(ts_remove) do pcall(vim.cmd, "TSUninstall " .. p) end
  end
end

-- ---- Mason ------------------------------------------------------------
local m_add    = split(vim.env.DEVLANG_MASON)
local m_remove = split(vim.env.DEVLANG_PRUNE_MASON)
if #m_add > 0 or #m_remove > 0 then
  local ok, mr = pcall(require, "mason-registry")
  if ok then
    mr.refresh()
    local valid = {}
    for _, n in ipairs(m_add) do
      if pcall(mr.get_package, n) then valid[#valid + 1] = n end
    end
    if #valid > 0 then
      log("mason +: " .. table.concat(valid, " "))
      pcall(vim.cmd, "MasonInstall " .. table.concat(valid, " ")) -- bloqueante em headless
    end
    if #m_remove > 0 then
      log("mason -: " .. table.concat(m_remove, " "))
      pcall(vim.cmd, "MasonUninstall " .. table.concat(m_remove, " "))
    end
  end
end

vim.cmd("qa!")
