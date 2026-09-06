-- provision.lua — roda via:  nvim --headless -u <init.lua> -c "luafile provision.lua"
--
-- Faz, de forma síncrona, o que o LazyVim faria numa 1ª abertura interativa:
--   1. Lazy sync (instala/atualiza plugins)
--   2. mason.nvim: instala as ferramentas base (formatters/linters, tree-sitter-cli)
--   3. nvim-treesitter (branch main): instala os parsers do ensure_installed
--   4. nvim-lspconfig + mason-lspconfig: instala os LSP servers dos extras ativos
--
-- Extras opcionais via variáveis de ambiente:
--   DEVLANG_TS="typescript tsx"        -> parsers adicionais
--   DEVLANG_MASON="prettier eslint-lsp" -> pacotes Mason adicionais

local function log(m) io.stderr:write("    [provision] " .. tostring(m) .. "\n") end

local function split(s)
  return vim.split(s or "", "%s+", { trimempty = true })
end

-- opts finais de um plugin (já com o merge feito pelos extras do LazyVim)
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

-- 1. plugins ---------------------------------------------------------------
log("Lazy sync…")
pcall(function() require("lazy").sync({ wait = true, show = false }) end)

-- 2. mason base ----------------------------------------------------------
load({ "mason.nvim" })
vim.wait(1500)
-- garante o mason/bin no PATH desta sessão (tree-sitter, etc.)
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
vim.env.PATH = mason_bin .. ":" .. (vim.env.PATH or "")

-- 3. treesitter (branch main: require('nvim-treesitter').install(langs):wait()) --
pcall(function()
  load({ "nvim-treesitter" })
  local want = plugin_opts("nvim-treesitter").ensure_installed
  if type(want) ~= "table" then want = {} end
  for _, p in ipairs(split(vim.env.DEVLANG_TS)) do want[#want + 1] = p end
  if #want > 0 then
    log("treesitter: " .. table.concat(want, " "))
    local nti = require("nvim-treesitter")
    local task = nti.install(want)
    if type(task) == "table" and task.wait then
      task:wait(600000)
    end
    log("treesitter ok: " .. table.concat(nti.get_installed(), " "))
  end
end)

-- 4. mason: LSP servers dos extras + ferramentas base ---------------------
load({ "mason-lspconfig.nvim", "nvim-lspconfig" })
vim.wait(2000)

local want = {}
pcall(function()
  local servers = plugin_opts("nvim-lspconfig").servers or {}
  local map = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
  for name, cfg in pairs(servers) do
    local off = type(cfg) == "table" and (cfg.enabled == false or cfg.mason == false)
    if not off and map[name] then want[map[name]] = true end
  end
end)
pcall(function()
  for _, t in ipairs(plugin_opts("mason.nvim").ensure_installed or {}) do want[t] = true end
end)
for _, p in ipairs(split(vim.env.DEVLANG_MASON)) do want[p] = true end

pcall(function()
  local mr = require("mason-registry")
  mr.refresh()
  local valid = {}
  for name in pairs(want) do
    if pcall(mr.get_package, name) then valid[#valid + 1] = name end
  end
  table.sort(valid)
  if #valid > 0 then
    log("mason: " .. table.concat(valid, " "))
    pcall(vim.cmd, "MasonInstall " .. table.concat(valid, " ")) -- bloqueante em headless
  end
  local done = {}
  for _, p in ipairs(mr.get_installed_packages()) do done[#done + 1] = p.name end
  table.sort(done)
  log("mason instalado: " .. table.concat(done, ", "))
end)

vim.cmd("qa!")
