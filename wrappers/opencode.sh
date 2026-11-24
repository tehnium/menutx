#!/usr/bin/env bash
# opencode - an AI coding agent for the terminal.
# Upstream: https://github.com/anomalyco/opencode (MIT)
# Runs as your user: its configuration, sessions and credentials live in
# your home and must not be created as root.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

BIN="${OPENCODE_BIN:-$HOME/.opencode/bin/opencode}"

if [[ ! -x $BIN ]]; then
  for candidate in "$HOME/.local/bin/opencode" "$(command -v opencode 2>/dev/null || true)"; do
    if [[ -n $candidate && -x $candidate ]]; then
      BIN=$candidate
      break
    fi
  done
fi

if [[ -z $BIN || ! -x $BIN ]]; then
  printf 'menutx: OpenCode 2 is not installed.\n' >&2
  printf '  Install it with: curl -fsSL https://opencode.ai/v2/install | bash\n' >&2
  exit 127
fi

exec "$BIN" "$@"
