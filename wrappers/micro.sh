#!/usr/bin/env bash
# micro - a modern text and Markdown editor for the terminal.
# Upstream: https://github.com/zyedidia/micro (MIT)
#
# Save with Ctrl-S, quit with Ctrl-Q.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v micro >/dev/null 2>&1; then
  printf 'menutx: micro is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

exec micro "$@"
