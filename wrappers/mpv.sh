#!/usr/bin/env bash
# mpv - video player rendered in the terminal, with an fzf file picker.
# Upstream: https://github.com/mpv-player/mpv (GPL-2.0-or-later)
#
# Use --vo=kitty or --vo=sixel for higher-quality graphics in terminals that
# support them; the default is --vo=tct, which works everywhere.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v mpv >/dev/null 2>&1; then
  printf 'menutx: mpv is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

args=("$@")

if (( ${#args[@]} == 0 )); then
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'Usage: %s FILE|URL\n' "${0##*/}" >&2
    exit 2
  fi
  mapfile -t picks < <(
    find "$HOME/Videos" "$HOME/Downloads" "$PWD" -maxdepth 2 -type f \
      \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.avi' \
         -o -iname '*.mov' -o -iname '*.m4v' -o -iname '*.mpg' -o -iname '*.mpeg' \
         -o -iname '*.ogv' -o -iname '*.ts' -o -iname '*.flv' \) 2>/dev/null \
      | LC_ALL=C sort -u 2>/dev/null | fzf --prompt='video> ' --height=80% --reverse
  )
  ((${#picks[@]})) || exit 0
  args=("${picks[@]}")
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
