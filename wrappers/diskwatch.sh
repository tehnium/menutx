#!/usr/bin/env bash
# diskwatch - disk, volume, filesystem, I/O and SMART diagnostics.
# Upstream: https://github.com/matthart1983/diskwatch (MIT)
# SMART data needs root, so this launcher uses sudo. --watch points at your
# home instead of /root, which is what sudo would otherwise use as $HOME.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="$DIR/bin/diskwatch"

if [[ ! -x $BIN ]]; then
  printf 'menutx: diskwatch is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

if ! command -v sudo >/dev/null 2>&1; then
  printf 'menutx: sudo is required to run diskwatch.\n' >&2
  exit 127
fi

# Do not add a second --watch if the caller already chose one.
for arg in "$@"; do
  case $arg in
    --watch|--watch=*)
      exec sudo -- "$BIN" "$@"
      ;;
  esac
done

exec sudo -- "$BIN" --watch "$HOME" "$@"
