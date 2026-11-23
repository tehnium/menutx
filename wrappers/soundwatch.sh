#!/usr/bin/env bash
# soundwatch - read-only audio diagnostics: devices, streams, meters,
# spectrum, latency, xruns and routing.
# Upstream: https://github.com/matthart1983/soundwatch (MIT)
# Runs as your user so it sees your sound server and your devices.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="$DIR/bin/soundwatch"

if [[ ! -x $BIN ]]; then
  printf 'menutx: soundwatch is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

exec "$BIN" "$@"
