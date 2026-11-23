#!/usr/bin/env bash
# nmon - Nigel's performance monitor for CPU, memory, disks and network.
# Upstream: https://nmon.sourceforge.net (GPL-3.0-or-later)
# Runs as your user; use nmon -f for unattended capture.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v nmon >/dev/null 2>&1; then
  printf 'menutx: nmon is not installed.\n' >&2
  printf '  Install it with: sudo apt install nmon\n' >&2
  exit 127
fi

exec nmon "$@"
