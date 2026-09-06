# shellcheck shell=bash
# Registro de linguagens para o devlang.
#
# Cada linguagem define uma função `lang_<id>` que exporta:
#   LABEL        -> nome exibido no menu
#   MISE_TOOLS   -> ferramentas para `mise use -g` (separadas por espaço), pode ser vazio
#   APT_PKGS     -> pacotes apt necessários (ex.: toolchain de build), pode ser vazio
#   LAZY_EXTRA   -> extra do LazyVim (ex.: lazyvim.plugins.extras.lang.go), pode ser vazio
#   MASON_PKGS   -> pacotes Mason extras a forçar (o extra do LazyVim já cobre o essencial)
#   POST_FN      -> nome de uma função opcional a rodar no fim
#
# Para adicionar uma linguagem nova: copie um bloco, ajuste os valores e
# acrescente o id em LANG_IDS (a ordem define a ordem do menu).

LANG_IDS=(
  go rust python typescript deno ruby lua c_cpp zig elixir java kotlin
  php bash sql terraform docker json yaml markdown tailwind astro svelte vue
)

lang_go() {
  LABEL="Go"
  MISE_TOOLS="go"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.go"
  MASON_PKGS=""
  POST_FN=""
}

lang_rust() {
  LABEL="Rust"
  MISE_TOOLS="rust"
  APT_PKGS="build-essential pkg-config libssl-dev"
  LAZY_EXTRA="lazyvim.plugins.extras.lang.rust"
  MASON_PKGS=""
  POST_FN="post_rust"
}
post_rust() {
  # rust-analyzer via rustup é mais confiável que via Mason
  if command -v rustup >/dev/null 2>&1; then
    rustup component add rust-analyzer clippy rustfmt 2>/dev/null || true
  fi
}

lang_python() {
  LABEL="Python"
  MISE_TOOLS="python"
  APT_PKGS="build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev"
  LAZY_EXTRA="lazyvim.plugins.extras.lang.python"
  MASON_PKGS=""
  POST_FN="post_python"
}
post_python() {
  command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh
}

lang_typescript() {
  LABEL="TypeScript / JavaScript (Node)"
  MISE_TOOLS="node"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.typescript"
  MASON_PKGS=""
  POST_FN=""
}

lang_deno() {
  LABEL="Deno"
  MISE_TOOLS="deno"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.deno"
  MASON_PKGS=""
  POST_FN=""
}

lang_ruby() {
  LABEL="Ruby"
  MISE_TOOLS="ruby"
  APT_PKGS="build-essential libssl-dev zlib1g-dev libyaml-dev libreadline-dev libffi-dev"
  LAZY_EXTRA="lazyvim.plugins.extras.lang.ruby"
  MASON_PKGS=""
  POST_FN=""
}

lang_lua() {
  LABEL="Lua (lua-language-server, stylua)"
  MISE_TOOLS=""
  APT_PKGS=""
  LAZY_EXTRA=""   # já é suporte nativo do LazyVim
  MASON_PKGS="lua-language-server stylua"
  POST_FN=""
}

lang_c_cpp() {
  LABEL="C / C++ (clangd)"
  MISE_TOOLS=""
  APT_PKGS="build-essential clang clangd lldb"
  LAZY_EXTRA="lazyvim.plugins.extras.lang.clangd"
  MASON_PKGS=""
  POST_FN=""
}

lang_zig() {
  LABEL="Zig"
  MISE_TOOLS="zig"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.zig"
  MASON_PKGS=""
  POST_FN=""
}

lang_elixir() {
  LABEL="Elixir / Erlang"
  MISE_TOOLS="erlang elixir"
  APT_PKGS="build-essential autoconf libncurses-dev libssl-dev"
  LAZY_EXTRA="lazyvim.plugins.extras.lang.elixir"
  MASON_PKGS=""
  POST_FN=""
}

lang_java() {
  LABEL="Java"
  MISE_TOOLS="java@temurin-21"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.java"
  MASON_PKGS=""
  POST_FN=""
}

lang_kotlin() {
  LABEL="Kotlin"
  MISE_TOOLS="kotlin java@temurin-21"
  APT_PKGS=""
  LAZY_EXTRA=""
  MASON_PKGS="kotlin-language-server ktlint"
  POST_FN=""
}

lang_php() {
  LABEL="PHP"
  MISE_TOOLS="php"
  APT_PKGS="build-essential libxml2-dev libsqlite3-dev libcurl4-openssl-dev libonig-dev re2c"
  LAZY_EXTRA="lazyvim.plugins.extras.lang.php"
  MASON_PKGS=""
  POST_FN=""
}

lang_bash() {
  LABEL="Bash / Shell"
  MISE_TOOLS=""
  APT_PKGS="shellcheck"
  LAZY_EXTRA=""
  MASON_PKGS="bash-language-server shfmt"
  POST_FN=""
}

lang_sql() {
  LABEL="SQL"
  MISE_TOOLS=""
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.sql"
  MASON_PKGS=""
  POST_FN=""
}

lang_terraform() {
  LABEL="Terraform / OpenTofu"
  MISE_TOOLS="terraform"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.terraform"
  MASON_PKGS=""
  POST_FN=""
}

lang_docker() {
  LABEL="Docker (dockerfile-ls, compose)"
  MISE_TOOLS=""
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.docker"
  MASON_PKGS=""
  POST_FN=""
}

lang_json() {
  LABEL="JSON"
  MISE_TOOLS=""
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.json"
  MASON_PKGS=""
  POST_FN=""
}

lang_yaml() {
  LABEL="YAML"
  MISE_TOOLS=""
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.yaml"
  MASON_PKGS=""
  POST_FN=""
}

lang_markdown() {
  LABEL="Markdown"
  MISE_TOOLS=""
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.markdown"
  MASON_PKGS=""
  POST_FN=""
}

lang_tailwind() {
  LABEL="Tailwind CSS"
  MISE_TOOLS=""
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.tailwind"
  MASON_PKGS=""
  POST_FN=""
}

lang_astro() {
  LABEL="Astro"
  MISE_TOOLS="node"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.astro"
  MASON_PKGS=""
  POST_FN=""
}

lang_svelte() {
  LABEL="Svelte"
  MISE_TOOLS="node"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.svelte"
  MASON_PKGS=""
  POST_FN=""
}

lang_vue() {
  LABEL="Vue"
  MISE_TOOLS="node"
  APT_PKGS=""
  LAZY_EXTRA="lazyvim.plugins.extras.lang.vue"
  MASON_PKGS=""
  POST_FN=""
}

# ==========================================================================
# Mapa parser(Treesitter) + LSP(Mason) + pack(astrocommunity) por linguagem.
# Usado quando o distro alvo NÃO é o LazyVim (AstroNvim / NvChad / kickstart),
# onde não há o conceito de "extra". No LazyVim o próprio extra já cobre isso.
# ==========================================================================
declare -A TS_MAP=(
  [go]="go gomod gowork gosum"      [rust]="rust"
  [python]="python"                 [typescript]="typescript tsx javascript jsdoc"
  [deno]="typescript tsx javascript" [ruby]="ruby"
  [lua]="lua luadoc"                [c_cpp]="c cpp"
  [zig]="zig"                       [elixir]="elixir eex heex"
  [java]="java"                     [kotlin]="kotlin"
  [php]="php phpdoc"                [bash]="bash"
  [sql]="sql"                       [terraform]="terraform hcl"
  [docker]="dockerfile"             [json]="json jsonc"
  [yaml]="yaml"                     [markdown]="markdown markdown_inline"
  [tailwind]="css"                  [astro]="astro"
  [svelte]="svelte"                 [vue]="vue"
)
declare -A LSP_MAP=(
  [go]="gopls"                      [rust]="rust-analyzer"
  [python]="basedpyright ruff"      [typescript]="vtsls"
  [deno]=""                         [ruby]="ruby-lsp"
  [lua]="lua-language-server"       [c_cpp]="clangd"
  [zig]="zls"                       [elixir]="elixir-ls"
  [java]="jdtls"                    [kotlin]="kotlin-language-server"
  [php]="phpactor"                  [bash]="bash-language-server"
  [sql]="sqlls"                     [terraform]="terraform-ls"
  [docker]="dockerfile-language-server" [json]="json-lsp"
  [yaml]="yaml-language-server"     [markdown]="marksman"
  [tailwind]="tailwindcss-language-server" [astro]="astro-language-server"
  [svelte]="svelte-language-server" [vue]="vue-language-server"
)
declare -A ASTRO_MAP=(
  [typescript]="typescript-all"     [c_cpp]="cpp"
  [markdown]="markdown"             [tailwind]="tailwindcss"
)
# demais linguagens: o pack do astrocommunity tem o mesmo nome do id
