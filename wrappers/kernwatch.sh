#!/usr/bin/env bash
# kernwatch - Linux kernel observability: CPU, scheduler, memory, block,
# syscalls, interrupts, cgroups and eBPF.
# Upstream: https://github.com/matthart1983/kernwatch (MIT)
# eBPF tracing needs root, so this launcher uses sudo.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="$DIR/bin/kernwatch"

if [[ ! -x $BIN ]]; then
  printf 'menutx: kernwatch is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

if ! command -v sudo >/dev/null 2>&1; then
  printf 'menutx: sudo is required to run kernwatch.\n' >&2
  exit 127
fi

exec sudo -- "$BIN" "$@"
