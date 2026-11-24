#!/usr/bin/env bash
# mc - Midnight Commander, a two-pane terminal file manager.
# Upstream: https://github.com/MidnightCommander/mc (GPL-3.0-or-later)
# Runs as your user so files are created with your ownership.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v mc >/dev/null 2>&1; then
  printf 'menutx: mc is not installed.\n' >&2
  printf '  Install it with: sudo apt install mc\n' >&2
  exit 127
fi

exec mc "$@"
