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
devlang              # unified menu — ○ available (installs) · ● installed (removes)
devlang go rust      # install directly
devlang -r go        # remove a language
devlang --remove     # menu with only the installed languages
devlang --list       # ids + what is installed
devlang --gui        # force the graphical menu (zenity)
```

Menus use `fzf` or `gum` if installed, otherwise `zenity`, otherwise a numbered list.

Or click **Dev Languages** in the Pop!_OS application menu (it asks install/remove).

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

## Removing a language

```bash
devlang -r go        # or: devlang --remove  (menu)
```

What happens:

1. removes `lazyvim.plugins.extras.lang.<x>` from `lazyvim.json`
2. `provision.lua` runs in _prune_ mode: uninstalls the **orphaned LSP servers and
   parsers** — whatever your LazyVim config no longer wants. Parsers LazyVim ships
   by default (e.g. `typescript`, `tsx`) **stay**, since LazyVim would reinstall
   them on the next boot
3. asks whether to also remove the **mise** runtime (`node`, `go`…) — your call,
   since you may use it outside the editor
4. `apt` packages (build-essential, headers…) are **not** removed (may be shared)

devlang records what it installed in `~/.local/state/devlang/installed`.

## Uninstalling devlang

```bash
rm ~/.local/bin/devlang ~/.local/share/applications/devlang.desktop
rm -rf ~/.local/share/devlang ~/.local/state/devlang
```

## License

MIT — see [LICENSE](LICENSE).
