-- provision.lua — roda via:  nvim --headless -u <init.lua> -c "luafile provision.lua"
--
-- Sincroniza o Neovim com o estado declarado em lazyvim.json, de forma síncrona
-- (em --headless o LazyVim não carrega os plugins lazy-loaded sozinho):
--   1. Lazy sync (instala/atualiza/remove plugins)
--   2. mason.nvim: ferramentas base (formatters/linters, tree-sitter-cli)
--   3. nvim-treesitter (branch main): parsers do ensure_installed
--   4. nvim-lspconfig + mason-lspconfig: LSP servers dos extras ativos
--
-- Env:
--   DEVLANG_TS="typescript tsx"          parsers adicionais a instalar
--   DEVLANG_MASON="prettier eslint-lsp"  pacotes Mason adicionais a instalar
--   DEVLANG_PRUNE=1                       remove parsers/pacotes que não são mais
--                                        desejados pela config (usado no uninstall)

local PRUNE = vim.env.DEVLANG_PRUNE == "1"

local function log(m) io.stderr:write("    [provision] " .. tostring(m) .. "\n") end
local function split(s) return vim.split(s or "", "%s+", { trimempty = true }) end

local function plugin_opts(name)
  local ok, Plugin = pcall(require, "lazy.core.plugin")
  local okc, Config = pcall(require, "lazy.core.config")
  if not (ok and okc) or not Config.plugins[name] then return {} end
  local ok2, o = pcall(Plugin.values, Config.plugins[name], "opts", false)
  return ok2 and o or {}
end

local function load(plugins)
  pcall(function() require("lazy").load({ plugins = plugins }) end)
end

local function set_of(list) local s = {} for _, v in ipairs(list) do s[v] = true end return s end

-- 1. plugins ---------------------------------------------------------------
log("Lazy sync…")
pcall(function() require("lazy").sync({ wait = true, show = false }) end)

-- 2. mason base ----------------------------------------------------------
load({ "mason.nvim" })
vim.wait(1500)
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. (vim.env.PATH or "")

-- ---- conjuntos desejados ---------------------------------------------------
load({ "nvim-treesitter", "mason-lspconfig.nvim", "nvim-lspconfig" })
vim.wait(2000)

local ts_want = plugin_opts("nvim-treesitter").ensure_installed
if type(ts_want) ~= "table" then ts_want = {} end
for _, p in ipairs(split(vim.env.DEVLANG_TS)) do ts_want[#ts_want + 1] = p end
local ts_desired = set_of(ts_want)

local mason_desired = {}
pcall(function()
  local servers = plugin_opts("nvim-lspconfig").servers or {}
  local map = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
  for name, cfg in pairs(servers) do
    local off = type(cfg) == "table" and (cfg.enabled == false or cfg.mason == false)
    if not off and map[name] then mason_desired[map[name]] = true end
  end
end)
for _, t in ipairs(plugin_opts("mason.nvim").ensure_installed or {}) do mason_desired[t] = true end
for _, p in ipairs(split(vim.env.DEVLANG_MASON)) do mason_desired[p] = true end
mason_desired["tree-sitter-cli"] = true -- dependência do nvim-treesitter (branch main)

-- 3. treesitter ----------------------------------------------------------
local nti = require("nvim-treesitter")
if #ts_want > 0 then
  log("treesitter: instalando " .. table.concat(ts_want, " "))
  pcall(function()
    local task = nti.install(ts_want)
    if type(task) == "table" and task.wait then task:wait(600000) end
  end)
end
if PRUNE then
  local orphans = {}
  for _, lang in ipairs(nti.get_installed()) do
    if not ts_desired[lang] then orphans[#orphans + 1] = lang end
  end
  if #orphans > 0 then
    log("treesitter: removendo " .. table.concat(orphans, " "))
    pcall(function()
      local task = nti.uninstall(orphans)
      if type(task) == "table" and task.wait then task:wait(120000) end
    end)
  end
end
pcall(function() log("treesitter ok: " .. table.concat(nti.get_installed(), " ")) end)

-- 4. mason -------------------------------------------------------------------
local mr = require("mason-registry")
mr.refresh()

local mason_install = {}
for name in pairs(mason_desired) do
  if pcall(mr.get_package, name) then mason_install[#mason_install + 1] = name end
end
table.sort(mason_install)
if #mason_install > 0 then
  log("mason: " .. table.concat(mason_install, " "))
  pcall(vim.cmd, "MasonInstall " .. table.concat(mason_install, " ")) -- bloqueante em headless
end

if PRUNE then
  local orphans = {}
  for _, p in ipairs(mr.get_installed_packages()) do
    if not mason_desired[p.name] then orphans[#orphans + 1] = p.name end
  end
  if #orphans > 0 then
    log("mason: removendo " .. table.concat(orphans, " "))
    pcall(vim.cmd, "MasonUninstall " .. table.concat(orphans, " "))
  end
end

pcall(function()
  local done = {}
  for _, p in ipairs(mr.get_installed_packages()) do done[#done + 1] = p.name end
  table.sort(done)
  log("mason instalado: " .. table.concat(done, ", "))
end)

vim.cmd("qa!")
