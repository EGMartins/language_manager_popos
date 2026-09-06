# language_manager_popos

[English](README.en.md) · **Português**

Utilitário estilo [Omarchy](https://omarchy.org) (`omarchy-install-dev-*`) para o
**Pop!_OS**: escolhe uma ou mais linguagens num menu e ele instala o runtime e
configura o **LazyVim** — parser do Treesitter, LSP via Mason, formatter/linter —
usando o "extra" oficial do LazyVim para cada linguagem.

## Instalação

```bash
git clone git@github.com:EGMartins/language_manager_popos.git
cd language_manager_popos
./install.sh
```

`install.sh` cria o symlink `~/.local/bin/devlang` e a entrada **Dev Languages** no
menu de aplicativos. É idempotente — rode de novo depois de um `git pull`.

## Uso

```bash
devlang              # menu unificado — ○ disponível (instala) · ● instalada (remove)
devlang go rust      # instala direto
devlang -r go        # remove a linguagem
devlang --remove     # menu só com as linguagens instaladas
devlang --list       # ids + o que está instalado
devlang --gui        # força o menu gráfico (zenity)
```

Menus: usa `fzf` ou `gum` se instalados, senão `zenity`, senão uma lista numerada.

Ou clique em **Dev Languages** no menu de aplicativos do Pop!_OS (pergunta
instalar/remover).

## O que cada instalação faz

1. `ensure_base` — instala `curl`, `git`, `build-essential` e o **mise**
   (gerenciador de runtimes, só quando a linguagem precisa de um)
2. `apt` — toolchain de build específico (ex.: headers para compilar Ruby/Python)
3. `mise use -g <tool>` — o runtime (Go, Node, Python…), global
4. adiciona `lazyvim.plugins.extras.lang.<x>` em `~/.config/nvim/lazyvim.json`
5. roda `provision.lua` em `nvim --headless`: `Lazy sync`, instala os parsers do
   Treesitter e os LSP servers/formatters via Mason (síncrono — carrega os plugins
   lazy-loaded antes de instalar)
6. passo final opcional (ex.: `rustup component add rust-analyzer`)

## Estrutura

| Arquivo | Papel |
|---|---|
| `devlang` | script principal (menu + instalação) |
| `registry.sh` | catálogo de linguagens — **edite aqui para adicionar/remover** |
| `provision.lua` | roda no `nvim --headless`: carrega os plugins e instala parser/LSP |
| `install.sh` | cria symlink + entrada de menu |
| `devlang.desktop.in` | template da entrada do menu de aplicativos |

## Adicionar uma linguagem

Em `registry.sh`, copie um bloco `lang_<id>()`, ajuste os campos e acrescente o
`<id>` em `LANG_IDS` (a ordem define a ordem no menu):

| Campo | Descrição |
|---|---|
| `LABEL` | nome exibido no menu |
| `MISE_TOOLS` | ferramentas para `mise use -g` (vazio = nenhuma) |
| `APT_PKGS` | pacotes apt (toolchain de build) |
| `LAZY_EXTRA` | extra do LazyVim, ex.: `lazyvim.plugins.extras.lang.go` |
| `MASON_PKGS` | pacotes Mason extras a forçar |
| `POST_FN` | nome de uma função opcional a rodar no fim |

Lista de extras: <https://www.lazyvim.org/extras>

## Remover uma linguagem

```bash
devlang -r go        # ou: devlang --remove  (menu)
```

O que acontece:

1. remove `lazyvim.plugins.extras.lang.<x>` do `lazyvim.json`
2. `provision.lua` roda em modo _prune_: desinstala os **LSP servers e parsers
   órfãos** — ou seja, o que não é mais desejado pela sua config do LazyVim.
   Parsers que o LazyVim já traz por padrão (ex.: `typescript`, `tsx`)
   **permanecem**, porque o LazyVim os reinstalaria no próximo boot
3. pergunta se quer remover o runtime do **mise** também (`node`, `go`…) — fica a
   seu critério, já que você pode usá-lo fora do editor
4. pacotes `apt` (build-essential, headers…) **não** são removidos (podem ser
   compartilhados com outras linguagens)

O devlang registra o que instalou em `~/.local/state/devlang/installed`.

## Desinstalar o devlang

```bash
rm ~/.local/bin/devlang ~/.local/share/applications/devlang.desktop
rm -rf ~/.local/share/devlang ~/.local/state/devlang
```

## Licença

MIT — veja [LICENSE](LICENSE).
