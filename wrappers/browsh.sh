#!/usr/bin/env bash
# browsh - a text-based web browser rendered by Firefox.
# Upstream: https://github.com/browsh-org/browsh (LGPL-2.1)
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v browsh >/dev/null 2>&1; then
  printf 'menutx: Browsh is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

FIREFOX=""
for candidate in "$(command -v firefox 2>/dev/null || true)" \
                 "$(command -v firefox-esr 2>/dev/null || true)"; do
  if [[ -n $candidate && -x $candidate ]]; then
    FIREFOX=$candidate
    break
  fi
done

if [[ -z $FIREFOX ]]; then
  printf 'menutx: Browsh needs Firefox (firefox or firefox-esr).\n' >&2
  printf '  Install it with: sudo apt install firefox-esr\n' >&2
  exit 127
fi

# Browsh expects its configuration directory to exist.
mkdir -p "$HOME/.config/browsh"

args=("$@")
if (( ${#args[@]} )) && [[ ${args[0]} != -* ]]; then
  url=${args[0]}
  args=("${args[@]:1}")
  exec browsh --firefox.path "$FIREFOX" --startup-url "$url" "${args[@]}"
fi

exec browsh --firefox.path "$FIREFOX" "${args[@]}"
