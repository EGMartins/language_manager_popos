# language_manager_popos

**English** · [Português](README.md)

Two [Omarchy](https://omarchy.org)-style utilities for **Pop!_OS**, with a single
in-terminal menu:

- **`devlang`** — pick languages; installs the runtime + wires up the editor
  (Treesitter parser, LSP via Mason, formatter). Full **LazyVim** support;
  **AstroNvim** and **NvChad** via detection of the active distro.
- **`deveditor`** — installs editors and Neovim distros: **LazyVim, AstroNvim,
  NvChad, kickstart** (side by side via `NVIM_APPNAME`) and **Neovim, Zed, VS Code,
  VSCodium, Helix, Emacs, Sublime Text, micro**.

## Install

```bash
git clone git@github.com:EGMartins/language_manager_popos.git
cd language_manager_popos
./install.sh
```

`install.sh` creates the `~/.local/bin/{devlang,deveditor}` symlinks and the
**Dev Languages** / **Dev Editors** application-menu entries. Idempotent — run it
again after a `git pull`.

## devlang

```bash
devlang                          # unified menu — ○ available (installs) · ● installed (removes)
devlang go rust                  # install directly
devlang -r go                    # remove a language
devlang --remove                 # menu with only the installed languages
devlang --list                   # ids + what is installed
devlang --appname astronvim go   # target another distro (see: deveditor --list)
devlang --gui                    # force the graphical menu (zenity)
```

Menu, in order of preference: `fzf` → `whiptail` (ships with Pop!_OS) → `gum` →
numbered list. All **inside the terminal, one window**. `zenity` is used only when
there is no terminal at all, or with `--gui`.

Or click **Dev Languages** in the application menu: opens one terminal with the
menu, installs/removes there, waits for ENTER at the end.

### What each install does

1. `ensure_base` — `curl`, `git`, `build-essential`, **mise** (only if the
   language needs a runtime)
2. `apt` — language-specific build toolchain (headers to compile Ruby/Python, …)
3. `mise use -g <tool>` — the runtime (Go, Node, Python…), global
4. **depends on the distro detected in `~/.config/nvim`** (or the `--appname` one):
   - **LazyVim** → adds `lazyvim.plugins.extras.lang.<x>` to `lazyvim.json`, runs
     `provision.lua` (`Lazy sync` + parser + LSP/formatter via Mason, loading the
     lazy-loaded plugins first)
   - **AstroNvim** → adds `{ import = "astrocommunity.pack.<x>" }` to
     `lua/community.lua` + installs parser and LSP (`provision_generic.lua`)
   - **NvChad / kickstart / unknown** → installs the Treesitter parser and the
     Mason LSP server directly; prints how to enable the server in the config
5. optional final step (e.g. `rustup component add rust-analyzer`)

Each distro keeps its own isolated Mason/parsers (`~/.local/share/<appname>/…`).

### Removing a language

```bash
devlang -r go        # or: devlang --remove  (menu)
```

1. removes the editor integration (LazyVim extra / astrocommunity import)
2. _prune_ mode: uninstalls the **LSP servers and parsers no other installed
   language still uses**. On LazyVim, parsers it ships by default (e.g.
   `typescript`) stay — it would reinstall them on next boot
3. asks whether to also remove the **mise** runtime — your call
4. `apt` packages are **not** removed (may be shared)

Per-distro state in `~/.local/state/devlang/<appname>.installed`.

## deveditor

```bash
deveditor                   # unified menu (○ installs · ● removes)
deveditor lazyvim zed       # install these
deveditor -r nvchad         # remove
deveditor --list            # what is available / installed
deveditor --replace lazyvim # install the distro INTO ~/.config/nvim (backs up first)
```

**Neovim distros go side by side** via `NVIM_APPNAME`: each becomes its own command
(`astronvim`, `nvchad`, `kickstart`) + an application-menu entry, with config in
`~/.config/<name>` and its own `share`/`state`/`cache`. Your `~/.config/nvim` is
untouched (unless `--replace`, which backs it up first).

Then: `devlang --appname astronvim go` installs Go into that specific distro.

Standalone editors: official apt repo (VS Code, VSCodium, Sublime), PPA (Helix),
official rootless script (Zed), GitHub tarball (Neovim), apt (Emacs, micro).
Removal undoes what can be undone (apt remove + drops the repo; leaves config).

## Layout

| File | Role |
|---|---|
| `devlang` | languages: menu + install + remove |
| `deveditor` | editors & Neovim distros: menu + install + remove |
| `lib.sh` | shared helpers (menu, colors, state, apt, confirm) |
| `registry.sh` | language catalog + per-language parser/LSP/pack map |
| `editors.sh` | editor/distro catalog |
| `provision.lua` | LazyVim: headless nvim loads plugins and installs/prunes parser/LSP |
| `provision_generic.lua` | AstroNvim/NvChad/kickstart: installs/removes parser+LSP directly |
| `install.sh` | creates the symlinks + menu entries |
| `*.desktop.in` | application-menu entry templates |

## Adding a language

In `registry.sh`, copy a `lang_<id>()` block, adjust the fields, append `<id>` to
`LANG_IDS` (order = menu order): `LABEL`, `MISE_TOOLS`, `APT_PKGS`, `LAZY_EXTRA`,
`MASON_PKGS`, `POST_FN`. Also add the parser/LSP to the `TS_MAP` / `LSP_MAP` (and
`ASTRO_MAP` if the astrocommunity pack name differs from the id) at the bottom of
`registry.sh` — used when the target is not LazyVim.

LazyVim extras: <https://www.lazyvim.org/extras> ·
astrocommunity packs: <https://github.com/AstroNvim/astrocommunity>

## Uninstalling

```bash
rm ~/.local/bin/{devlang,deveditor} \
   ~/.local/share/applications/{devlang,deveditor}.desktop
rm -rf ~/.local/state/{devlang,deveditor}
# distros installed via deveditor: remove them with `deveditor -r <id>` first
```

## License

MIT — see [LICENSE](LICENSE).
