#!/usr/bin/env bash
# mpv - video player rendered in the terminal, with a directory picker.
# Upstream: https://github.com/mpv-player/mpv (GPL-2.0-or-later)
#
# Use --vo=kitty or --vo=sixel for higher-quality graphics in terminals that
# support them; the default is --vo=tct, which works everywhere.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="mpv"

if ! command -v "$BIN" >/dev/null 2>&1; then
  printf 'menutx: mpv is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

args=("$@")

if (( ${#args[@]} == 0 )); then
  if [[ ! -x $DIR/_pick.sh ]]; then
    printf 'Usage: %s FILE|URL\n' "${0##*/}" >&2
    exit 2
  fi
  picked=$("$DIR/_pick.sh" video) || exit 0
  args=("$picked")
fi

have_vo=0
for arg in "${args[@]}"; do
  case $arg in
    --vo|--vo=*) have_vo=1 ;;
  esac
done
if (( ! have_vo )); then
  args=(--vo=tct "${args[@]}")
fi

exec mpv --quiet "${args[@]}"
