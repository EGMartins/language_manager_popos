# language_manager_popos

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
devlang              # menu (fzf/gum se instalado; senão janela zenity)
devlang go rust      # instala direto
devlang --list       # ids disponíveis
devlang --gui        # força o menu gráfico (zenity)
```

Ou clique em **Dev Languages** no menu de aplicativos do Pop!_OS.

## O que cada instalação faz

1. `ensure_base` — instala `curl`, `git`, `build-essential` e o **mise**
   (gerenciador de runtimes, só quando a linguagem precisa de um)
2. `apt` — toolchain de build específico (ex.: headers para compilar Ruby/Python)
3. `mise use -g <tool>` — o runtime (Go, Node, Python…), global
4. adiciona `lazyvim.plugins.extras.lang.<x>` em `~/.config/nvim/lazyvim.json`
5. `nvim --headless` — `Lazy! sync`, `TSUpdateSync`, `Mason`
6. passo final opcional (ex.: `rustup component add rust-analyzer`)

## Estrutura

| Arquivo | Papel |
|---|---|
| `devlang` | script principal (menu + instalação) |
| `registry.sh` | catálogo de linguagens — **edite aqui para adicionar/remover** |
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

## Desinstalar

```bash
rm ~/.local/bin/devlang ~/.local/share/applications/devlang.desktop
# runtimes continuam no mise:  mise ls  /  mise uninstall <tool>
# extras continuam no lazyvim.json:  nvim +LazyExtras
```

## Licença

MIT — veja [LICENSE](LICENSE).
