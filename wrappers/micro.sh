#!/usr/bin/env bash
# micro - a modern text and Markdown editor for the terminal.
# Upstream: https://github.com/zyedidia/micro (MIT)
#
# Save with Ctrl-S, quit with Ctrl-Q.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v micro >/dev/null 2>&1; then
  printf 'menutx: micro is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

if (( $# == 0 )) && [[ -x $DIR/_pick.sh ]]; then
  picked=$("$DIR/_pick.sh" text) || exit 0
  exec micro "$picked"
fi

exec micro "$@"
