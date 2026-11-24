#!/usr/bin/env bash
# cmus - a music player and library for the terminal.
# Upstream: https://github.com/cmus/cmus (GPL-2.0)
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v cmus >/dev/null 2>&1; then
  printf 'menutx: cmus is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

exec cmus "$@"
