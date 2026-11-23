#!/usr/bin/env bash
# menutx uninstaller - removes the install folder and the ~/.bashrc alias.
# Packages installed with apt are left alone, as are tool configs in $HOME.
#
# Project: https://github.com/tehnium/menutx
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

SELF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MARK_START="# >>> menutx >>>"
MARK_END="# <<< menutx <<<"
ASSUME_YES=0
DIR=""

usage() {
  cat <<EOF
menutx uninstaller

Usage: ./uninstall.sh [--yes]

Removes the menutx folder and the menutx alias block from ~/.bashrc.
apt packages, ~/.config data and ~/.opencode are not touched.

Options:
  -y, --yes    do not ask for confirmation
  -h, --help   show this help
EOF
}

while (( $# )); do
  case $1 in
    -y|--yes) ASSUME_YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'uninstall: unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done

if (( EUID == 0 )); then
  if [[ -z ${SUDO_USER:-} || ${SUDO_USER:-} == root ]]; then
    printf 'uninstall: run this as your normal user, not from a root shell.\n' >&2
    exit 1
  fi
  TARGET_USER=$SUDO_USER
else
  TARGET_USER=$(id -un)
fi

TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
[[ -n $TARGET_HOME && -d $TARGET_HOME ]] || {
  printf 'uninstall: cannot find the home directory of %s.\n' "$TARGET_USER" >&2
  exit 1
}
TARGET_GROUP=$(id -gn "$TARGET_USER")

# Prefer the folder this script lives in; allow running the copy from the
# repository, which falls back to the default install location.
DIR=$SELF_DIR
# An installed folder has both menutx.sh and bin/. The repository clone has
# menutx.sh too, so the bin/ check keeps ./uninstall.sh in the clone from
# deleting the clone itself.
if [[ ! ( -f $DIR/menutx.sh && -d $DIR/bin ) ]]; then
  if [[ -f $TARGET_HOME/menutx/menutx.sh && -d $TARGET_HOME/menutx/bin ]]; then
    DIR="$TARGET_HOME/menutx"
  else
    printf 'uninstall: no menutx installation found (looked in %s and %s).\n' \
      "$SELF_DIR" "$TARGET_HOME/menutx" >&2
    exit 1
  fi
fi

case $DIR in
  /|/home|/usr|/etc|/var|/opt|"$TARGET_HOME")
    printf 'uninstall: refusing to remove %s.\n' "$DIR" >&2
    exit 1
    ;;
esac
if [[ ${DIR#/} != */* ]]; then
  printf 'uninstall: refusing to remove %s.\n' "$DIR" >&2
  exit 1
fi

printf '\nThis will remove:\n'
printf '  %s\n' "$DIR"
printf '  the menutx alias block in %s/.bashrc (if present)\n\n' "$TARGET_HOME"
printf 'apt packages, ~/.config data and ~/.opencode are not removed.\n\n'

if (( ! ASSUME_YES )); then
  if [[ ! -t 0 ]]; then
    printf 'uninstall: no terminal for confirmation; re-run with --yes.\n' >&2
    exit 1
  fi
  printf 'Continue? [y/N] '
  read -r answer
  case ${answer:-} in
    [yY]|[yY][eE][sS]) ;;
    *) printf 'Cancelled.\n'; exit 0 ;;
  esac
fi

rc="$TARGET_HOME/.bashrc"
if [[ -f $rc ]] && grep -qF -- "$MARK_START" "$rc"; then
  cp -p -- "$rc" "$rc.menutx-uninstall.bak"
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
  if (( EUID == 0 )); then
    chown "$TARGET_USER:$TARGET_GROUP" "$rc" "$rc.menutx-uninstall.bak"
  fi
  printf 'Removed the menutx alias from %s\n' "$rc"
else
  printf 'No menutx alias block found in %s\n' "$rc"
fi

cd /
rm -rf -- "$DIR"
printf 'Removed %s\n' "$DIR"
printf 'Open a new shell to drop the alias from your current environment.\n'
