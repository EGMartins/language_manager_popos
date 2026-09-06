# language_manager_popos

**English** · [Português](README.md)

An [Omarchy](https://omarchy.org)-style utility (`omarchy-install-dev-*`) for
**Pop!_OS**: pick one or more languages from a menu and it installs the runtime and
configures **LazyVim** — Treesitter parser, LSP via Mason, formatter/linter —
using LazyVim's official "extra" for each language.

## Install

```bash
git clone git@github.com:EGMartins/language_manager_popos.git
cd language_manager_popos
./install.sh
```

`install.sh` creates the `~/.local/bin/devlang` symlink and the **Dev Languages**
entry in the application menu. It is idempotent — run it again after a `git pull`.

## Usage

```bash
devlang              # menu (fzf/gum if installed; otherwise a zenity window)
devlang go rust      # install directly
devlang --list       # available ids
devlang --gui        # force the graphical menu (zenity)
```

Or click **Dev Languages** in the Pop!_OS application menu.

## What each install does

1. `ensure_base` — installs `curl`, `git`, `build-essential` and **mise**
   (runtime manager, only when the language needs one)
2. `apt` — language-specific build toolchain (e.g. headers to compile Ruby/Python)
3. `mise use -g <tool>` — the runtime (Go, Node, Python…), global
4. adds `lazyvim.plugins.extras.lang.<x>` to `~/.config/nvim/lazyvim.json`
5. runs `provision.lua` under `nvim --headless`: `Lazy sync`, installs Treesitter
   parsers and LSP servers/formatters via Mason (synchronously — it loads the
   lazy-loaded plugins before installing)
6. optional final step (e.g. `rustup component add rust-analyzer`)

## Layout

| File | Role |
|---|---|
| `devlang` | main script (menu + install) |
| `registry.sh` | language catalog — **edit here to add/remove** |
| `provision.lua` | runs under `nvim --headless`: loads plugins and installs parser/LSP |
| `install.sh` | creates symlink + menu entry |
| `devlang.desktop.in` | template for the application-menu entry |

## Adding a language

In `registry.sh`, copy a `lang_<id>()` block, adjust the fields and append the
`<id>` to `LANG_IDS` (order defines the menu order):

| Field | Description |
|---|---|
| `LABEL` | name shown in the menu |
| `MISE_TOOLS` | tools for `mise use -g` (empty = none) |
| `APT_PKGS` | apt packages (build toolchain) |
| `LAZY_EXTRA` | LazyVim extra, e.g. `lazyvim.plugins.extras.lang.go` |
| `MASON_PKGS` | extra Mason packages to force-install |
| `POST_FN` | name of an optional function to run at the end |

Extras list: <https://www.lazyvim.org/extras>

## Uninstall

```bash
rm ~/.local/bin/devlang ~/.local/share/applications/devlang.desktop
# runtimes stay in mise:  mise ls  /  mise uninstall <tool>
# extras stay in lazyvim.json:  nvim +LazyExtras
```

## License

MIT — see [LICENSE](LICENSE).
