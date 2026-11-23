#!/usr/bin/env bash
# hyfetch - neofetch with LGBTQ+ pride flags.
# Upstream: https://github.com/hykilpikonna/hyfetch (MIT)
# Runs as your user so the first-run configuration lands in your home.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

BIN=""
for candidate in "${HYFETCH_BIN:-}" "$HOME/.local/bin/hyfetch" "$(command -v hyfetch 2>/dev/null || true)"; do
  if [[ -n $candidate && -x $candidate ]]; then
    BIN=$candidate
    break
  fi
done

if [[ -z $BIN ]]; then
  printf 'menutx: hyfetch is not installed.\n' >&2
  printf '  Install it with: sudo apt install hyfetch\n' >&2
  exit 127
fi

exec "$BIN" "$@"
