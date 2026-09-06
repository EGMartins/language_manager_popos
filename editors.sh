# shellcheck shell=bash
# editors.sh — catálogo do deveditor.
#
# Dois tipos de item:
#   distro_<id>()  distros de Neovim  (config em ~/.config/<appname>, lado a lado via NVIM_APPNAME)
#   app_<id>()     editores standalone (apt / flatpak / script oficial)
#
# distro_<id> exporta: LABEL, REPO, APPNAME, KIND(lazy|custom), DESC
# app_<id>    exporta: LABEL, CHECK(comando), INSTALL_FN, REMOVE_FN, DESC

# ============================ distros de Neovim ============================
DISTRO_IDS=(lazyvim astronvim nvchad kickstart)

distro_lazyvim() {
  LABEL="LazyVim"
  REPO="https://github.com/LazyVim/starter"
  APPNAME="lazyvim"
  KIND="lazy"
  DESC="Distro keyboard-first sobre lazy.nvim; base do devlang"
}
distro_astronvim() {
  LABEL="AstroNvim"
  REPO="https://github.com/AstroNvim/template"
  APPNAME="astronvim"
  KIND="lazy"
  DESC="Config modular com o ecossistema astrocommunity"
}
distro_nvchad() {
  LABEL="NvChad"
  REPO="https://github.com/NvChad/starter"
  APPNAME="nvchad"
  KIND="lazy"
  DESC="Leve e rápido, UI própria (base46)"
}
distro_kickstart() {
  LABEL="kickstart.nvim"
  REPO="https://github.com/nvim-lua/kickstart.nvim"
  APPNAME="kickstart"
  KIND="lazy"
  DESC="init.lua único, pra aprender e customizar do zero"
}

# ============================ editores standalone =========================
APP_IDS=(neovim zed vscode vscodium helix emacs sublime-text micro)

app_neovim() {
  LABEL="Neovim (última estável)"
  CHECK="nvim"; INSTALL_FN=install_neovim; REMOVE_FN=remove_neovim
  DESC="Instala/atualiza pra release estável mais recente do GitHub"
}
app_zed() {
  LABEL="Zed"
  CHECK="zed"; INSTALL_FN=install_zed; REMOVE_FN=remove_zed
  DESC="Editor rápido em Rust (script oficial, sem root)"
}
app_vscode() {
  LABEL="Visual Studio Code"
  CHECK="code"; INSTALL_FN=install_vscode; REMOVE_FN=remove_vscode
  DESC="Repo apt oficial da Microsoft"
}
app_vscodium() {
  LABEL="VSCodium"
  CHECK="codium"; INSTALL_FN=install_vscodium; REMOVE_FN=remove_vscodium
  DESC="VS Code sem a telemetria da Microsoft (repo apt)"
}
app_helix() {
  LABEL="Helix"
  CHECK="hx"; INSTALL_FN=install_helix; REMOVE_FN=remove_helix
  DESC="Editor modal em Rust, sem plugins (PPA)"
}
app_emacs() {
  LABEL="Emacs"
  CHECK="emacs"; INSTALL_FN=install_emacs; REMOVE_FN=remove_emacs
  DESC="apt (emacs-gtk)"
}
app_sublime-text() {
  LABEL="Sublime Text"
  CHECK="subl"; INSTALL_FN=install_sublime; REMOVE_FN=remove_sublime
  DESC="Repo apt oficial"
}
app_micro() {
  LABEL="micro"
  CHECK="micro"; INSTALL_FN=install_micro; REMOVE_FN=remove_micro
  DESC="Editor de terminal simples (apt)"
}

# --------------------------- funções de app ------------------------------
_add_apt_repo() {  # $1 nome  $2 url-da-chave  $3 linha-do-repo (use SIGNEDBY como placeholder)
  local name="$1" keyurl="$2" repoline="$3"
  local key="/usr/share/keyrings/${name}-keyring.gpg"
  local list="/etc/apt/sources.list.d/${name}.list"
  say "Adicionando repositório apt: $name"
  say "  chave:  $keyurl"
  curl -fsSL "$keyurl" | gpg --dearmor | sudo tee "$key" >/dev/null
  repoline="${repoline/SIGNEDBY/signed-by=$key}"
  say "  repo :  $repoline"
  echo "$repoline" | sudo tee "$list" >/dev/null
  sudo apt-get update -qq
}
_del_apt_repo() {
  local name="$1"
  sudo rm -f "/usr/share/keyrings/${name}-keyring.gpg" "/etc/apt/sources.list.d/${name}.list"
}

install_neovim() {
  local want ver
  if have nvim; then
    ver="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo 0)"
    say "Neovim atual: v$ver"
    confirm "Baixar/atualizar para a última release estável?" || { ok "mantido"; return 0; }
  fi
  local arch tarball
  case "$(uname -m)" in
    x86_64) arch="linux-x86_64" ;;
    aarch64) arch="linux-arm64" ;;
    *) die "arquitetura não suportada para o tarball do Neovim: $(uname -m)" ;;
  esac
  tarball="nvim-${arch}.tar.gz"
  say "Baixando $tarball (GitHub releases/stable)"
  local tmp; tmp="$(mktemp -d)"
  curl -fL "https://github.com/neovim/neovim/releases/download/stable/${tarball}" -o "$tmp/nvim.tar.gz" \
    || { curl -fL "https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz" -o "$tmp/nvim.tar.gz" || { rm -rf "$tmp"; die "download falhou"; }; }
  sudo rm -rf /opt/nvim
  sudo mkdir -p /opt/nvim
  sudo tar -xzf "$tmp/nvim.tar.gz" -C /opt/nvim --strip-components=1
  sudo ln -sfn /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmp"
  ok "Neovim -> $(/usr/local/bin/nvim --version | head -1)"
}
remove_neovim() {
  if [[ -L /usr/local/bin/nvim && "$(readlink -f /usr/local/bin/nvim)" == /opt/nvim/* ]]; then
    sudo rm -f /usr/local/bin/nvim; sudo rm -rf /opt/nvim
    ok "Neovim (/opt/nvim) removido"
  else
    warn "nvim não foi instalado pelo deveditor (/opt/nvim); não removido"
  fi
}

install_zed() {
  say "Instalando Zed via script oficial: https://zed.dev/install.sh"
  confirm "Executar 'curl -fsSL https://zed.dev/install.sh | sh'?" || die "cancelado"
  curl -fsSL https://zed.dev/install.sh | sh
  ok "Zed em ~/.local/bin/zed"
}
remove_zed() {
  rm -rf ~/.local/bin/zed ~/.local/share/zed ~/.zed_server
  ok "Zed removido (config em ~/.config/zed mantida)"
}

install_vscode() {
  apt_install curl gpg
  _add_apt_repo microsoft https://packages.microsoft.com/keys/microsoft.asc \
    "deb [arch=amd64,arm64,armhf SIGNEDBY] https://packages.microsoft.com/repos/code stable main"
  sudo apt-get install -y code
}
remove_vscode() { sudo apt-get remove -y code || true; _del_apt_repo microsoft; }

install_vscodium() {
  apt_install curl gpg
  _add_apt_repo vscodium https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    "deb [SIGNEDBY] https://download.vscodium.com/debs vscodium main"
  sudo apt-get install -y codium
}
remove_vscodium() { sudo apt-get remove -y codium || true; _del_apt_repo vscodium; }

install_helix() {
  apt_install software-properties-common
  say "Adicionando PPA ppa:maveonair/helix-editor"
  sudo add-apt-repository -y ppa:maveonair/helix-editor
  sudo apt-get update -qq
  sudo apt-get install -y helix
}
remove_helix() {
  sudo apt-get remove -y helix || true
  sudo add-apt-repository -y --remove ppa:maveonair/helix-editor || true
}

install_emacs() { apt_install emacs-gtk || apt_install emacs; }
remove_emacs()  { sudo apt-get remove -y emacs emacs-gtk emacs-common || true; }

install_sublime() {
  apt_install curl gpg
  _add_apt_repo sublimehq https://download.sublimetext.com/sublimehq-pub.gpg \
    "deb [SIGNEDBY] https://download.sublimetext.com/ apt/stable/"
  sudo apt-get install -y sublime-text
}
remove_sublime() { sudo apt-get remove -y sublime-text || true; _del_apt_repo sublimehq; }

install_micro() { apt_install micro; }
remove_micro()  { sudo apt-get remove -y micro || true; }
