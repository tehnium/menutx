#!/usr/bin/env bash
# chafa - image and GIF viewer for the terminal, with an fzf file picker.
# Upstream: https://github.com/hpjansson/chafa (LGPL-3.0)
#
# The default symbols mode works in every terminal. Use -f kitty or -f sixels
# for higher quality in terminals that support those protocols.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v chafa >/dev/null 2>&1; then
  printf 'menutx: chafa is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

args=("$@")

if (( ${#args[@]} == 0 )); then
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'Usage: %s IMAGE\n' "${0##*/}" >&2
    exit 2
  fi
  mapfile -t picks < <(
    find "$HOME/Pictures" "$HOME/Downloads" "$PWD" -maxdepth 2 -type f \
      \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' \
         -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.tif' -o -iname '*.tiff' \
         -o -iname '*.avif' -o -iname '*.svg' -o -iname '*.qoi' \) 2>/dev/null \
      | LC_ALL=C sort -u 2>/dev/null | fzf --prompt='image> ' --height=80% --reverse
  )
  ((${#picks[@]})) || exit 0
  args=("${picks[@]}")
fi

exec chafa "${args[@]}"
