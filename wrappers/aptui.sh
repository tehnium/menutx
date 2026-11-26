#!/usr/bin/env bash
# aptui - a TUI package manager for APT-based systems: browse, search,
# install, remove, upgrade and clean up packages.
# Upstream: https://github.com/mexirica/aptui (MIT)
# aptui runs under sudo so it can perform package operations; that is also
# how upstream documents it (`sudo aptui`). Its history, pins and error log
# live in ~/.local/share/aptui of the user behind the sudo call.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="$DIR/bin/aptui"

if [[ ! -x $BIN ]]; then
  printf 'menutx: aptui is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

if (( EUID == 0 )); then
  exec "$BIN" "$@"
fi

printf 'aptui needs sudo to install, remove and upgrade packages.\n' >&2
exec sudo -- "$BIN" "$@"
