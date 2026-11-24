#!/usr/bin/env bash
# menutx installer - sets up ~/menutx on Debian-based systems.
#
# Creates the install folder, installs system packages, downloads the latest
# Linux release of each diagnostics tool from GitHub, verifies checksums when
# the project publishes them, writes the launchers, and adds a shell alias.
#
# Project: https://github.com/tehnium/menutx
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

APP="menutx"
MENUTX_VERSION="1.1.1"
# Browsh 1.8.3 exists, but it ships only the XPI; 1.8.2 is the latest
# release with Linux .deb packages.
BROWSH_VERSION="1.8.2"
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Pinned fallbacks. The installer prefers each project's latest release and
# only uses these when the GitHub API is unavailable or the asset is missing.
# Format: tool|owner/repo|tag|amd64 asset|arm64 asset|armv5te asset
MANIFEST=$(cat <<'EOF'
syswatch|matthart1983/syswatch|v0.14.5|syswatch-linux-x86_64.tar.gz|syswatch-linux-aarch64.tar.gz|syswatch-linux-armv5te-static.tar.gz
netwatch|matthart1983/netwatch|v1.0.0|netwatch-linux-x86_64.tar.gz|netwatch-linux-aarch64.tar.gz|netwatch-linux-armv5te.tar.gz
diskwatch|matthart1983/diskwatch|v0.7.2|diskwatch-linux-x86_64.tar.gz|diskwatch-linux-aarch64.tar.gz|diskwatch-linux-armv5te.tar.gz
kernwatch|matthart1983/kernwatch|v0.5.1|kernwatch-linux-x86_64.tar.gz|kernwatch-linux-aarch64.tar.gz|
netscan|matthart1983/netscan|v0.8.1|netscan-linux-x86_64-static.tar.gz|netscan-linux-aarch64-static.tar.gz|
soundwatch|matthart1983/soundwatch|v0.2.0|soundwatch-linux-x86_64.tar.gz|soundwatch-linux-aarch64.tar.gz|
EOF
)

# Packages every launcher may need. nmap is a hard dependency of netscan,
# smartmontools feeds diskwatch's SMART tab, libpulse0 is loaded at runtime
# by soundwatch, and alsa-utils brings the ALSA tools and library.
APT_PACKAGES=(
  ca-certificates curl gzip tar xz-utils
  sudo
  mc nmon nmap smartmontools
  alsa-utils libpulse0
  iproute2 procps
  mpv cmus chafa fzf micro
)

# Options
TARGET_USER=""
TARGET_HOME=""
TARGET_GROUP=""
INSTALL_DIR=""
USE_LATEST=1
INSTALL_DEPS=1
INSTALL_OPENCODE=1
INSTALL_BROWSH=1
ADD_ALIAS=1
TMP_DIR=""

MARK_START="# >>> menutx >>>"
MARK_END="# <<< menutx <<<"

if [[ -t 1 ]]; then
  C_BOLD=$'\e[1m' C_DIM=$'\e[2m' C_YEL=$'\e[33m' C_RED=$'\e[31m' C_OFF=$'\e[0m'
else
  C_BOLD="" C_DIM="" C_YEL="" C_RED="" C_OFF=""
fi

say()  { printf '%s==>%s %s\n' "$C_BOLD" "$C_OFF" "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '%swarning:%s %s\n' "$C_YEL" "$C_OFF" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }

usage() {
  cat <<EOF
menutx $MENUTX_VERSION installer

Usage: ./install.sh [OPTIONS]

Options:
  --dir PATH       install into PATH (default: ~/menutx)
  --pinned         use the pinned versions; do not ask GitHub for the latest
  --no-deps        skip apt packages (and the hyfetch and Browsh installs)
  --no-browsh      do not install Browsh or its Firefox dependency
  --no-opencode    do not install OpenCode 2
  --no-alias       do not add the menutx alias to ~/.bashrc
  -h, --help       show this help and exit

Environment:
  GITHUB_TOKEN     optional token, used for GitHub API rate limits

The installer must run as your normal user (it calls sudo when needed).
EOF
}

cleanup_tmp() {
  if [[ -n ${TMP_DIR:-} && -d $TMP_DIR ]]; then
    rm -rf -- "$TMP_DIR"
  fi
}
trap cleanup_tmp EXIT

# ---------------------------------------------------------------- arguments

while (( $# )); do
  case $1 in
    --dir)
      [[ $# -ge 2 ]] || die "--dir needs a path"
      INSTALL_DIR=$2
      shift 2
      ;;
    --dir=*)
      INSTALL_DIR=${1#*=}
      shift
      ;;
    --pinned)
      USE_LATEST=0
      shift
      ;;
    --no-deps)
      INSTALL_DEPS=0
      shift
      ;;
    --no-browsh)
      INSTALL_BROWSH=0
      shift
      ;;
    --no-opencode)
      INSTALL_OPENCODE=0
      shift
      ;;
    --no-alias)
      ADD_ALIAS=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1 (try --help)"
      ;;
  esac
done

# --------------------------------------------------------------- environment

if (( EUID == 0 )); then
  if [[ -z ${SUDO_USER:-} || ${SUDO_USER:-} == root ]]; then
    die "run the installer as your normal user, not from a root shell (it will ask for sudo)."
  fi
  TARGET_USER=$SUDO_USER
else
  TARGET_USER=$(id -un)
fi

TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
[[ -n $TARGET_HOME && -d $TARGET_HOME ]] || die "cannot find the home directory of $TARGET_USER."
TARGET_GROUP=$(id -gn "$TARGET_USER")

if [[ -z $INSTALL_DIR ]]; then
  INSTALL_DIR="$TARGET_HOME/menutx"
else
  case $INSTALL_DIR in
    "~")   INSTALL_DIR=$TARGET_HOME ;;
    "~/"*) INSTALL_DIR="$TARGET_HOME/${INSTALL_DIR#\~/}" ;;
  esac
  [[ $INSTALL_DIR == /* ]] || INSTALL_DIR="$PWD/$INSTALL_DIR"
  if command -v realpath >/dev/null 2>&1; then
    INSTALL_DIR=$(realpath -m -- "$INSTALL_DIR")
  fi
  while [[ $INSTALL_DIR == */ && $INSTALL_DIR != / ]]; do
    INSTALL_DIR=${INSTALL_DIR%/}
  done
fi

SOURCE_REAL=$(realpath -m -- "$SOURCE_DIR" 2>/dev/null || printf '%s' "$SOURCE_DIR")
if [[ $INSTALL_DIR == "$SOURCE_REAL" ]]; then
  die "the repository and the install target are the same directory ($INSTALL_DIR). Clone the repository somewhere else (for example ~/menutx-src) and run install.sh from there, or pass --dir with a different target."
fi

case $INSTALL_DIR in
  /|/home|/usr|/etc|/var|/opt|"$TARGET_HOME")
    die "refusing to install into $INSTALL_DIR; choose a subdirectory."
    ;;
esac
if [[ ${INSTALL_DIR#/} != */* ]]; then
  die "refusing to install into $INSTALL_DIR; choose a subdirectory."
fi

command -v apt-get >/dev/null 2>&1 || die "apt-get not found. This installer targets Debian-based systems."

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
fi
case "${ID:-} ${ID_LIKE:-}" in
  *debian*|*ubuntu*) ;;
  *) warn "this does not look like a Debian-based system; continuing anyway." ;;
esac

[[ -f $SOURCE_DIR/menutx.sh ]] || die "menutx.sh is missing next to install.sh (run the installer from a clone of the repository)."
[[ -d $SOURCE_DIR/wrappers ]] || die "the wrappers/ directory is missing (run the installer from a clone of the repository)."
[[ -f $SOURCE_DIR/uninstall.sh ]] || die "uninstall.sh is missing next to install.sh."

if (( EUID != 0 && INSTALL_DEPS )); then
  command -v sudo >/dev/null 2>&1 || die "sudo is required. On a minimal Debian install, run: su -c 'apt-get update && apt-get install -y sudo', then add your user to the sudo group and log back in."
fi

TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/menutx.XXXXXX")

printf '\n  %s%s %s installer%s\n' "$C_BOLD" "$APP" "$MENUTX_VERSION" "$C_OFF"
printf '  %sterminal tools for Debian-based systems%s\n\n' "$C_DIM" "$C_OFF"

if (( EUID != 0 && INSTALL_DEPS )); then
  say "Requesting sudo privileges"
  sudo -v || die "sudo authentication failed."
fi

# ------------------------------------------------------------------ helpers

as_user() {
  if (( EUID == 0 )); then
    sudo -u "$TARGET_USER" -H -- "$@"
  else
    "$@"
  fi
}

run_apt() {
  if (( EUID == 0 )); then
    DEBIAN_FRONTEND=noninteractive apt-get -y "$@"
  else
    sudo -- env DEBIAN_FRONTEND=noninteractive apt-get -y "$@"
  fi
}

download() {
  local url=$1 dest=$2
  info "  $url"
  curl -fL --progress-bar --retry 3 --retry-delay 2 --connect-timeout 20 --max-time 600 \
    -o "$dest" "$url"
}

latest_tag() {
  local repo=$1
  local -a headers=(-H 'Accept: application/vnd.github+json')
  if [[ -n ${GITHUB_TOKEN:-} ]]; then
    headers+=(-H "Authorization: Bearer $GITHUB_TOKEN")
  fi
  curl -fsSL --max-time 20 "${headers[@]}" \
    "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null \
    | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n1
}

verify_checksum() {
  local repo=$1 tag=$2 asset=$3 work=$4
  local sums="$work/SHA256SUMS"
  local line

  if ! curl -fsSL --max-time 30 -o "$sums" \
      "https://github.com/$repo/releases/download/$tag/SHA256SUMS" 2>/dev/null; then
    info "  no SHA256SUMS published for this release"
    return 0
  fi

  line=$(awk -v a="$asset" '$2 == a || $2 == ("*" a) { print; exit }' "$sums")
  if [[ -z $line ]]; then
    warn "no checksum entry for $asset"
    return 0
  fi

  if printf '%s\n' "$line" | (cd "$work" && sha256sum -c -); then
    info "  checksum OK"
  else
    return 1
  fi
}

install_tool() {
  local tool=$1 repo=$2 pinned=$3 asset=$4
  local tag=$pinned
  local latest=""
  local work="$TMP_DIR/$tool"
  local tarball="$work/$asset"
  local bin_name="${asset%.tar.gz}"
  local bin="$INSTALL_DIR/$tool/$bin_name"

  if (( USE_LATEST )); then
    latest=$(latest_tag "$repo" || true)
    if [[ -n $latest ]]; then
      tag=$latest
    else
      warn "could not query the latest release of $tool; using $pinned"
    fi
  fi

  say "$tool $tag"
  mkdir -p "$work"

  if ! download "https://github.com/$repo/releases/download/$tag/$asset" "$tarball"; then
    if [[ $tag != "$pinned" ]]; then
      warn "$asset is not present in $tag; falling back to $pinned"
      tag=$pinned
      download "https://github.com/$repo/releases/download/$tag/$asset" "$tarball" \
        || die "could not download $tool"
    else
      die "could not download $tool"
    fi
  fi

  verify_checksum "$repo" "$tag" "$asset" "$work" \
    || die "checksum verification failed for $tool"

  rm -rf -- "$INSTALL_DIR/$tool"
  mkdir -p "$INSTALL_DIR/$tool"
  if ! tar -xzf "$tarball" -C "$INSTALL_DIR/$tool" --no-same-owner; then
    die "could not extract the $tool archive"
  fi

  [[ -f $bin ]] || die "the $tool archive did not contain $bin_name"
  chmod 0755 "$bin"
  ln -sfn "../$tool/$bin_name" "$INSTALL_DIR/bin/$tool"
  info "  installed to $bin"
}

verify_browsh_checksum() {
  local asset=$1 work=$2
  local sums="$work/browsh_${BROWSH_VERSION}_checksums.txt"
  local line

  if ! curl -fsSL --max-time 30 -o "$sums" \
      "https://github.com/browsh-org/browsh/releases/download/v${BROWSH_VERSION}/browsh_${BROWSH_VERSION}_checksums.txt" 2>/dev/null; then
    warn "Browsh checksums are not available for $BROWSH_VERSION"
    return 0
  fi

  line=$(awk -v a="$asset" '$2 == a || $2 == ("*" a) { print; exit }' "$sums")
  if [[ -z $line ]]; then
    warn "no checksum entry for $asset"
    return 0
  fi

  if printf '%s\n' "$line" | (cd "$work" && sha256sum -c -); then
    info "  checksum OK"
  else
    return 1
  fi
}

install_browsh() {
  local arch=""
  local asset=""
  local work="$TMP_DIR/browsh"

  case $(uname -m) in
    x86_64|amd64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    armv7l) arch=armv7 ;;
    armv6l) arch=armv6 ;;
    *)
      warn "Browsh has no .deb for $(uname -m); skipping it"
      return 1
      ;;
  esac

  asset="browsh_${BROWSH_VERSION}_linux_${arch}.deb"
  say "Browsh $BROWSH_VERSION"
  mkdir -p "$work"

  if ! download "https://github.com/browsh-org/browsh/releases/download/v${BROWSH_VERSION}/${asset}" "$work/$asset"; then
    warn "could not download Browsh; skipping it"
    return 1
  fi

  if ! verify_browsh_checksum "$asset" "$work"; then
    warn "Browsh checksum verification failed; skipping it"
    return 1
  fi

  info "  installing the .deb (this pulls Firefox if it is missing)"
  if ! run_apt install "$work/$asset"; then
    warn "Browsh could not be installed; skipping it"
    return 1
  fi

  if ! command -v browsh >/dev/null 2>&1; then
    warn "Browsh was installed but the browsh command is not in PATH; skipping it"
    return 1
  fi

  as_user mkdir -p "$TARGET_HOME/.config/browsh" 2>/dev/null || true
  info "  installed $(command -v browsh)"
  return 0
}

add_alias() {
  local rc="$TARGET_HOME/.bashrc"
  local alias_line=""
  local tmp=""

  touch "$rc"
  cp -p -- "$rc" "$rc.menutx.bak"

  tmp=$(mktemp)
  awk -v s="$MARK_START" -v e="$MARK_END" '
    $0 == s { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip { lines[++n] = $0 }
    END {
      while (n > 0 && lines[n] == "") n--
      for (i = 1; i <= n; i++) print lines[i]
    }
  ' "$rc" > "$tmp"
  cat "$tmp" > "$rc"
  rm -f -- "$tmp"

  alias_line=$(printf 'alias menutx=%q' "bash $INSTALL_DIR/menutx.sh")
  {
    printf '\n%s\n' "$MARK_START"
    printf '%s\n' "$alias_line"
    printf '%s\n' "$MARK_END"
  } >> "$rc"

  if (( EUID == 0 )); then
    chown "$TARGET_USER:$TARGET_GROUP" "$rc" "$rc.menutx.bak"
  fi

  info "alias added to $rc"
}

# ------------------------------------------------------------------- system

if (( INSTALL_DEPS )); then
  say "Installing Debian packages"
  run_apt update
  run_apt install --no-install-recommends "${APT_PACKAGES[@]}"

  if apt-cache show hyfetch >/dev/null 2>&1; then
    say "Installing hyfetch"
    run_apt install --no-install-recommends hyfetch
  else
    say "hyfetch is not packaged for this release; installing it with pip"
    run_apt install --no-install-recommends python3 python3-pip
    if ! as_user python3 -m pip install --user --upgrade hyfetch 2>/dev/null; then
      as_user python3 -m pip install --user --upgrade --break-system-packages hyfetch \
        || warn "hyfetch could not be installed; the menu entry will explain how to add it later."
    fi
  fi
else
  say "Skipping apt packages (--no-deps)"
fi

command -v curl >/dev/null 2>&1 || die "curl is required. Install it with: sudo apt install curl"

# -------------------------------------------------------------------- tools

say "Installing the diagnostics tools into $INSTALL_DIR"
mkdir -p "$INSTALL_DIR/bin"

SKIPPED_TOOLS=()
case $(uname -m) in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  armv7l|armv6l|armv5te|armv5tel|arm) ARCH=armhf ;;
  *) die "unsupported CPU architecture: $(uname -m) (supported: x86_64, aarch64, armv7l/armv5te)" ;;
esac

while IFS='|' read -r tool repo pinned amd64 arm64 armhf; do
  if [[ -z $tool || $tool == \#* ]]; then
    continue
  fi
  asset=""
  case $ARCH in
    amd64) asset=$amd64 ;;
    arm64) asset=$arm64 ;;
    armhf) asset=$armhf ;;
  esac
  if [[ -z $asset ]]; then
    warn "$tool has no published build for $ARCH; skipping it"
    SKIPPED_TOOLS+=("$tool")
    continue
  fi
  install_tool "$tool" "$repo" "$pinned" "$asset"
done <<< "$MANIFEST"

if (( INSTALL_DEPS && INSTALL_BROWSH )); then
  if ! install_browsh; then
    SKIPPED_TOOLS+=("browsh")
  fi
else
  if (( ! INSTALL_DEPS )); then
    warn "skipping Browsh because --no-deps was used"
  elif (( ! INSTALL_BROWSH )); then
    say "Skipping Browsh (--no-browsh)"
  fi
  SKIPPED_TOOLS+=("browsh")
fi

if (( ${#SKIPPED_TOOLS[@]} )); then
  for tool in "${SKIPPED_TOOLS[@]}"; do
    rm -f -- "$INSTALL_DIR/bin/$tool"
  done
fi

# ------------------------------------------------------------------- files

say "Installing the menu and launchers"
install -m 0755 "$SOURCE_DIR/menutx.sh" "$INSTALL_DIR/menutx.sh"
install -m 0755 "$SOURCE_DIR/uninstall.sh" "$INSTALL_DIR/uninstall.sh"
if [[ -f $SOURCE_DIR/LICENSE ]]; then
  install -m 0644 "$SOURCE_DIR/LICENSE" "$INSTALL_DIR/LICENSE"
fi

SKIP_WRAPPERS=()
if (( INSTALL_OPENCODE )); then
  say "Installing OpenCode 2"
  if as_user bash -c 'curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path'; then
    info "OpenCode 2 is installed in ~/.opencode/bin"
  else
    warn "OpenCode 2 could not be installed. Install it later with: curl -fsSL https://opencode.ai/v2/install | bash"
  fi
else
  SKIP_WRAPPERS+=("opencode.sh")
  rm -f -- "$INSTALL_DIR/opencode.sh"
  say "Skipping OpenCode 2 (--no-opencode)"
fi

shopt -s nullglob
for wrapper in "$SOURCE_DIR"/wrappers/*.sh; do
  name=$(basename -- "$wrapper")
  skip=0
  for s in "${SKIP_WRAPPERS[@]}"; do
    if [[ $name == "$s" ]]; then
      skip=1
    fi
  done
  for tool in "${SKIPPED_TOOLS[@]}"; do
    if [[ $name == "$tool.sh" ]]; then
      skip=1
    fi
  done
  if (( skip )); then
    continue
  fi
  install -m 0755 "$wrapper" "$INSTALL_DIR/$name"
done

if (( ${#SKIPPED_TOOLS[@]} )); then
  for tool in "${SKIPPED_TOOLS[@]}"; do
    rm -f -- "$INSTALL_DIR/$tool.sh"
  done
fi

if (( ADD_ALIAS )); then
  add_alias
else
  say "Skipping the ~/.bashrc alias (--no-alias)"
fi

if (( EUID == 0 )); then
  chown -R "$TARGET_USER:$TARGET_GROUP" "$INSTALL_DIR"
fi

# ------------------------------------------------------------------- summary

printf '\n'
say "menutx $MENUTX_VERSION is ready in $INSTALL_DIR"
printf '\n'
if (( ADD_ALIAS )); then
  printf '  Start it in a new shell with:\n\n'
  printf '    menutx\n\n'
  printf '  Or load the alias in this shell first:\n\n'
  printf '    source %q\n\n' "$TARGET_HOME/.bashrc"
else
  printf '  Start it with:\n\n'
  printf '    %q\n\n' "$INSTALL_DIR/menutx.sh"
fi
printf '  Remove it later with:\n\n'
printf '    %q\n\n' "$INSTALL_DIR/uninstall.sh"
printf '  The launchers ask for your sudo password only when a tool needs root.\n'
printf '  Upstream tools: https://github.com/matthart1983\n\n'

if (( ADD_ALIAS )) && [[ ${SHELL:-} == */zsh ]]; then
  warn "your login shell is zsh: the alias was written to ~/.bashrc only. Run the menu directly, or add the same alias to ~/.zshrc."
fi
