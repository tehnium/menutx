#!/usr/bin/env bash
# netscan - an nmap workflow in the terminal: targets, profiles, live scans
# and scan history.
# Upstream: https://github.com/matthart1983/netscan (MIT)
# Raw scans need root (and nmap must be installed), so this launcher uses sudo.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="$DIR/bin/netscan"

if [[ ! -x $BIN ]]; then
  printf 'menutx: netscan is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

if ! command -v sudo >/dev/null 2>&1; then
  printf 'menutx: sudo is required to run netscan.\n' >&2
  exit 127
fi

exec sudo -- "$BIN" "$@"
