# language_manager_popos

[English](README.en.md) · **Português**

Dois utilitários estilo [Omarchy](https://omarchy.org) para o **Pop!_OS**, com menu
único no terminal:

- **`devlang`** — escolhe linguagens e instala o runtime + configura o editor
  (parser do Treesitter, LSP via Mason, formatter). Suporte completo ao **LazyVim**;
  **AstroNvim** e **NvChad** via detecção do distro ativo.
- **`deveditor`** — instala editores e distros de Neovim: **LazyVim, AstroNvim,
  NvChad, kickstart** (lado a lado via `NVIM_APPNAME`) e **Neovim, Zed, VS Code,
  VSCodium, Helix, Emacs, Sublime Text, micro**.

## Instalação

```bash
git clone git@github.com:EGMartins/language_manager_popos.git
cd language_manager_popos
./install.sh
```

`install.sh` cria os symlinks `~/.local/bin/{devlang,deveditor}` e as entradas
**Dev Languages** / **Dev Editors** no menu de aplicativos. É idempotente — rode de
novo depois de um `git pull`.

## deveditor

```bash
deveditor                   # menu unificado (○ instala · ● remove)
deveditor lazyvim zed       # instala esses itens
deveditor -r nvchad         # remove
deveditor --list            # o que está disponível/instalado
deveditor --replace lazyvim # instala o distro EM ~/.config/nvim (faz backup)
```

**Distros de Neovim ficam lado a lado** via `NVIM_APPNAME`: cada um vira um comando
(`astronvim`, `nvchad`, `kickstart`) + entrada no menu de aplicativos, com config em
`~/.config/<nome>`, `share`/`state`/`cache` próprios. Seu `~/.config/nvim` não é
tocado (a não ser com `--replace`, que faz backup antes).

Depois: `devlang --appname astronvim go` instala Go naquele distro específico.

Editores standalone: repo apt oficial (VS Code, VSCodium, Sublime), PPA (Helix),
script oficial sem root (Zed), tarball do GitHub (Neovim), apt (Emacs, micro).
Remover desfaz o que deu pra desfazer (apt remove + tira o repo; não mexe em config).

## Uso

```bash
devlang              # menu unificado — ○ disponível (instala) · ● instalada (remove)
devlang go rust      # instala direto
devlang -r go        # remove a linguagem
devlang --remove     # menu só com as linguagens instaladas
devlang --list       # ids + o que está instalado
devlang --gui        # força o menu gráfico (zenity)
```

Menu, em ordem de preferência: `fzf` → `whiptail` (já vem no Pop!_OS) → `gum` →
lista numerada. Tudo **dentro do terminal, numa janela só**. O `zenity` só entra
quando não há terminal nenhum, ou com `--gui`.

Ou clique em **Dev Languages** no menu de aplicativos do Pop!_OS: abre um terminal
com o menu (uma janela), instala/remove ali mesmo e espera um ENTER no fim.

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
| `devlang` | linguagens: menu + instalação + remoção |
| `deveditor` | editores e distros de Neovim: menu + instalação + remoção |
| `lib.sh` | helpers compartilhados (menu, cores, estado, apt, confirm) |
| `registry.sh` | catálogo de linguagens — **edite aqui p/ adicionar/remover** |
| `editors.sh` | catálogo de editores/distros |
| `provision.lua` | roda no `nvim --headless`: carrega plugins e instala/poda parser/LSP |
| `install.sh` | cria os symlinks + entradas de menu |
| `*.desktop.in` | templates das entradas do menu de aplicativos |

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
