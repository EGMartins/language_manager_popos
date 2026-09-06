# shellcheck shell=bash
# lib.sh — helpers compartilhados por devlang e deveditor.
# Quem faz source deve definir DEVTOOL (nome exibido nos menus) antes.

DEVTOOL="${DEVTOOL:-dev}"

c_reset=$'\e[0m'; c_bold=$'\e[1m'; c_blue=$'\e[34m'; c_green=$'\e[32m'; c_yellow=$'\e[33m'; c_red=$'\e[31m'
say()  { printf '%s\n' "${c_blue}${c_bold}::${c_reset} $*"; }
ok()   { printf '%s\n' "${c_green}  ✓${c_reset} $*"; }
warn() { printf '%s\n' "${c_yellow}  !${c_reset} $*" >&2; }
die()  { printf '%s\n' "${c_red}${c_bold}erro:${c_reset} $*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---- estado (arquivo de linhas; $1 = caminho, $2 = item) -----------------
sf_has()  { [[ -f "$1" ]] && grep -qxF "$2" "$1"; }
sf_list() { [[ -f "$1" ]] && cat "$1" || true; }
sf_add()  { mkdir -p "$(dirname "$1")"; sf_has "$1" "$2" || printf '%s\n' "$2" >> "$1"; }
sf_del() {
  [[ -f "$1" ]] || return 0
  grep -vxF "$2" "$1" > "$1.tmp" 2>/dev/null || : > "$1.tmp"
  mv "$1.tmp" "$1"
}

# ---- confirmação -------------------------------------------------------
# ASSUME_YES=1 -> sempre sim.  Sem terminal utilizável e sem ASSUME_YES -> não.
confirm() {
  local q="$1" a
  [[ "${ASSUME_YES:-0}" == 1 ]] && return 0
  { : </dev/tty; } 2>/dev/null || return 1
  printf '%s%s%s [s/N] ' "${c_yellow}" "$q" "${c_reset}" >&2
  read -r a </dev/tty 2>/dev/null || return 1
  [[ "$a" =~ ^[sSyY]$ ]]
}

# ---- apt: instala só o que falta ---------------------------------------
apt_install() {
  local p pending=()
  for p in "$@"; do [[ -n "$p" ]] && { dpkg -s "$p" >/dev/null 2>&1 || pending+=("$p"); }; done
  ((${#pending[@]})) || return 0
  say "apt: ${pending[*]}"
  sudo apt-get update -qq && sudo apt-get install -y "${pending[@]}"
}

# ---- menu: rows no stdin ("id<TAB>on|off<TAB>display"), ids no stdout ----
# Prioriza menus DENTRO do terminal (uma janela só). zenity só sem tty / --gui.
choose() {
  local header="$1" rows; rows="$(cat)"
  [[ -z "$rows" ]] && return 0
  local id flag disp

  if [[ "${FORCE_ZENITY:-0}" != 1 && -t 2 ]] && have fzf; then
    printf '%s\n' "$rows" | fzf --multi --delimiter='\t' --with-nth=3 \
      --height=100% --border --reverse --prompt="$DEVTOOL> " \
      --header="$header"$'\n''TAB marca · ENTER confirma · ESC cancela' | cut -f1

  elif [[ "${FORCE_ZENITY:-0}" != 1 && -t 2 ]] && have whiptail; then
    local args=() rowcount n
    while IFS=$'\t' read -r id flag disp; do args+=("$id" "$disp" off); done <<< "$rows"
    rowcount=$(printf '%s\n' "$rows" | grep -c .); n=$rowcount; ((n > 14)) && n=14
    whiptail --title "$DEVTOOL" --notags --separate-output \
      --checklist "$header"$'\n''(ESPAÇO marca · ENTER confirma)' $((n + 9)) 82 "$n" \
      "${args[@]}" 3>&1 1>&2 2>&3 </dev/tty

  elif [[ "${FORCE_ZENITY:-0}" != 1 && -t 2 ]] && have gum; then
    local sel d; sel="$(printf '%s\n' "$rows" | cut -f3 | gum choose --no-limit --header "$header")"
    while IFS= read -r d; do
      [[ -z "$d" ]] && continue
      printf '%s\n' "$rows" | awk -F'\t' -v d="$d" '$3==d{print $1}'
    done <<< "$sel"

  elif [[ "${FORCE_ZENITY:-0}" != 1 && -t 2 ]]; then
    local ids=() disps=() i nums nn
    while IFS=$'\t' read -r id flag disp; do ids+=("$id"); disps+=("$disp"); done <<< "$rows"
    printf '\n%s\n' "$header" >&2
    for i in "${!ids[@]}"; do printf '  %2d) %s\n' "$((i + 1))" "${disps[$i]}" >&2; done
    printf '\nnúmeros (separados por espaço): ' >&2
    read -r nums </dev/tty || true
    for nn in $nums; do [[ "$nn" =~ ^[0-9]+$ ]] && printf '%s\n' "${ids[$((nn - 1))]:-}"; done

  elif have zenity; then
    local args=()
    while IFS=$'\t' read -r id flag disp; do args+=(FALSE "$id" "$disp"); done <<< "$rows"
    zenity --list --checklist --width=520 --height=620 \
      --title="$DEVTOOL" --text="$header" \
      --column="" --column="id" --column="Item" --hide-column=2 --print-column=2 \
      "${args[@]}" 2>/dev/null | tr '|' '\n'
  else
    die "sem fzf/whiptail/gum/zenity e sem terminal; passe os ids na linha de comando"
  fi
}

# retorna "install" | "remove" | ""  (para launch gráfico puro)
gui_pick_action() {
  case "$(zenity --list --radiolist --width=340 --height=230 --title="$DEVTOOL" \
            --text="O que deseja fazer?" --column="" --column="ação" \
            TRUE "Instalar" FALSE "Remover" 2>/dev/null)" in
    Remover*)   echo remove ;;
    Instalar*)  echo install ;;
    *)          echo "" ;;
  esac
}

# menu de aplicativos abre um terminal; não deixa fechar na cara do usuário
desktop_close_prompt() {
  [[ "${DEVLANG_LAUNCHER:-}" == desktop && -e /dev/tty ]] || return 0
  printf '\n%s' "Pressione ENTER para fechar… " >&2
  read -r _ </dev/tty || true
}
