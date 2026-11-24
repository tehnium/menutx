#!/usr/bin/env bash
# syswatch - live CPU, memory, disk, process, GPU, power and network diagnostics.
# Upstream: https://github.com/matthart1983/syswatch (MIT)
# syswatch is read-only by design and does not need root.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="$DIR/bin/syswatch"

if [[ ! -x $BIN ]]; then
  printf 'menutx: syswatch is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

exec "$BIN" "$@"
