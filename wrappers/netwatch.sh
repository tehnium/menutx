#!/usr/bin/env bash
# netwatch - network connections, per-hop latency, packet capture and diagnosis.
# Upstream: https://github.com/matthart1983/netwatch (MIT)
# Packet capture needs elevated privileges, so this launcher uses sudo.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="$DIR/bin/netwatch"

if [[ ! -x $BIN ]]; then
  printf 'menutx: netwatch is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

if ! command -v sudo >/dev/null 2>&1; then
  printf 'menutx: sudo is required to run netwatch.\n' >&2
  exit 127
fi

exec sudo -- "$BIN" "$@"
