#!/usr/bin/env bash
# menutx - a terminal menu for the diagnostics tools installed in this folder.
#
# Keys: Up/Down or j/k to move, Home/End or g/G to jump, Enter to launch,
#       r to rescan the folder, q to quit.
#
# Project: https://github.com/tehnium/menutx
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

VERSION="1.1.1"
SELF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SELF="$(basename -- "${BASH_SOURCE[0]}")"

# Shown first, in this order. Any other launcher in the folder follows
# alphabetically, so dropping a new executable here is enough to list it.
PINNED_FIRST=(syswatch netwatch diskwatch kernwatch netscan soundwatch \
  browsh mpv cmus chafa micro)

declare -a NAMES=()
declare -A TARGET=()
declare -A DESC=()

DESC=(
  [syswatch]="CPU, memory, disks, processes and power"
  [netwatch]="Connections, latency and packet capture"
  [diskwatch]="Disks, filesystems, I/O and SMART health"
  [kernwatch]="Kernel, eBPF, scheduler and interrupts"
  [netscan]="nmap scans and attack-surface workflow"
  [soundwatch]="Audio devices, streams and meters"
  [browsh]="Text-based web browser (Firefox)"
  [mpv]="Video player with terminal output"
  [cmus]="Music player and library"
  [chafa]="Image and GIF viewer"
  [micro]="Text and Markdown editor"
  [hyfetch]="Neofetch with pride flags"
  [mc]="Midnight Commander file manager"
  [nmon]="Nigel's performance monitor"
  [opencode]="AI coding agent in the terminal"
)

SEL=0
MENU_ACTIVE=0

if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
  ESC=$'\e'
  BOLD="${ESC}[1m"
  DIM="${ESC}[2m"
  RESET="${ESC}[0m"
  HL="${ESC}[7m"
  CLR="${ESC}[2J${ESC}[H"
  HIDE="${ESC}[?25l"
  SHOW="${ESC}[?25h"
else
  ESC=""
  BOLD="" DIM="" RESET="" HL="" CLR="" HIDE="" SHOW=""
fi

cleanup() {
  (( MENU_ACTIVE )) || return 0
  stty sane 2>/dev/null || true
  printf '%s%s' "$SHOW" "$RESET"
}
trap cleanup EXIT INT TERM

usage() {
  cat <<EOF
menutx $VERSION - terminal menu for local diagnostics tools

Usage: ${SELF} [OPTIONS]

Options:
  --list       print the launcher names and exit
  --version    print the version and exit
  -h, --help   show this help and exit

Keys:
  Up/Down, j/k    move the selection
  Home/End, g/G   jump to the first or last entry
  Enter           launch the selected tool
  r               rescan this folder for launchers
  q               quit
EOF
}

# Collect launchers: prefer a .sh wrapper, otherwise an executable binary.
scan() {
  local f b short
  local -a ordered=() rest=()
  local n p skip

  TARGET=()
  shopt -s nullglob

  for f in "$SELF_DIR"/*.sh; do
    b=${f##*/}
    [[ $b == "$SELF" || $b == "uninstall.sh" || $b == "install.sh" ]] && continue
    [[ -f $f && -x $f ]] || continue
    TARGET[${b%.sh}]=$f
  done

  for f in "$SELF_DIR"/*; do
    [[ -f $f && -x $f ]] || continue
    b=${f##*/}
    [[ $b == "$SELF" || $b == "uninstall.sh" || $b == "install.sh" ]] && continue
    case $b in
      *.sh) continue ;;
      *-linux-*) short=${b%%-linux-*} ;;
      *) short=$b ;;
    esac
    [[ -n ${TARGET[$short]+x} ]] || TARGET[$short]=$f
  done

  NAMES=()
  if (( ${#TARGET[@]} == 0 )); then
    return 0
  fi

  mapfile -t NAMES < <(printf '%s\n' "${!TARGET[@]}" | LC_ALL=C sort)

  for n in "${PINNED_FIRST[@]}"; do
    [[ -n ${TARGET[$n]+x} ]] && ordered+=("$n")
  done
  for n in "${NAMES[@]}"; do
    skip=0
    for p in "${PINNED_FIRST[@]}"; do
      [[ $n == "$p" ]] && skip=1
    done
    (( skip )) || rest+=("$n")
  done
  NAMES=("${ordered[@]}" "${rest[@]}")

  (( SEL >= ${#NAMES[@]} )) && SEL=0
}

draw() {
  local i name desc
  printf '%s%s' "$CLR" "$HIDE"
  printf '\n  %smenutx%s %s\n' "$BOLD" "$RESET" "$VERSION"
  printf '  %sTerminal tools on Debian - %d launchers%s\n\n' \
    "$DIM" "${#NAMES[@]}" "$RESET"
  for i in "${!NAMES[@]}"; do
    name=${NAMES[i]}
    desc=${DESC[$name]:-}
    if (( i == SEL )); then
      printf '  %s> %-12s%s %s\n' "$HL" "$name" "$RESET" "$desc"
    else
      printf '    %-12s %s\n' "$name" "$desc"
    fi
  done
  printf '\n  %sUp/Down move - Enter launch - r rescan - q quit%s\n' \
    "$DIM" "$RESET"
}

launch() {
  (( ${#NAMES[@]} )) || return 1
  local name=${NAMES[SEL]} target=${TARGET[${NAMES[SEL]}]} rc
  printf '%s%s' "$SHOW" "$RESET"
  printf '%s' "$CLR"
  printf 'Launching %s...\n\n' "$name"
  "$target"
  rc=$?
  stty sane 2>/dev/null || true
  printf '\n%s%s exited with status %d.%s\n' "$DIM" "$name" "$rc" "$RESET"
  printf 'Press Enter to return to the menu... '
  IFS= read -r _ || true
}

run_menu() {
  local key rest
  MENU_ACTIVE=1
  while :; do
    draw
    key=
    IFS= read -rsn1 key || return 0
    if [[ -n $ESC && $key == "$ESC" ]]; then
      IFS= read -rsn2 -t 0.05 rest || rest=
      key+=$rest
    fi
    case $key in
      "${ESC}[A"|k) (( SEL > 0 )) && (( SEL-- )) ;;
      "${ESC}[B"|j) (( SEL < ${#NAMES[@]} - 1 )) && (( SEL++ )) ;;
      "${ESC}[H"|g) SEL=0 ;;
      "${ESC}[F"|G) SEL=$(( ${#NAMES[@]} - 1 )) ;;
      ""|$'\n'|$'\r') launch ;;
      "$ESC"|q|Q) return 0 ;;
      r|R)
        scan
        (( ${#NAMES[@]} )) || return 0
        ;;
    esac
  done
}

LIST=0
for arg in "$@"; do
  case $arg in
    --list) LIST=1 ;;
    --version|-V) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *)
      printf 'menutx: unknown option: %s\n\n' "$arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

scan

if (( LIST )); then
  if (( ${#NAMES[@]} )); then
    printf '%s\n' "${NAMES[@]}"
  fi
  exit 0
fi

if (( ${#NAMES[@]} == 0 )); then
  printf 'No launchers found in %s\n' "$SELF_DIR" >&2
  printf 'Run the installer again, or put an executable .sh wrapper in that folder.\n' >&2
  exit 1
fi

if [[ ! -t 0 || ! -t 1 ]]; then
  # No interactive terminal: fall back to a numbered list.
  for i in "${!NAMES[@]}"; do
    printf '%2d) %s\n' $((i + 1)) "${NAMES[i]}"
  done
  printf 'Number: '
  read -r n || exit 1
  [[ $n =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#NAMES[@]} )) || exit 1
  SEL=$((n - 1))
  launch
  exit 0
fi

run_menu
