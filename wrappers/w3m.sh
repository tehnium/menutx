#!/usr/bin/env bash
# w3m - a stable text-based web browser, with no JavaScript engine.
# Upstream: https://w3m.sourceforge.net/ (MIT)
#
# This is the reliable fallback when Browsh crashes on a heavy page.
# Keys: U = URL, H = help, / = search, q = quit, Ctrl-L = redraw.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v w3m >/dev/null 2>&1; then
  printf 'menutx: w3m is not installed.\n' >&2
  printf '  Install it with: sudo apt install w3m\n' >&2
  exit 127
fi

normalize_url() {
  local in=$1
  case $in in
    http://*|https://*|about:*|file://*)
      printf '%s' "$in"
      ;;
    *" "*)
      in=${in// /+}
      printf 'https://lite.duckduckgo.com/lite/?q=%s' "$in"
      ;;
    *.*)
      printf 'https://%s' "$in"
      ;;
    *)
      in=${in// /+}
      printf 'https://lite.duckduckgo.com/lite/?q=%s' "$in"
      ;;
  esac
}

target=""
if (( $# == 0 )); then
  printf 'w3m - type a URL or a search (Enter = DuckDuckGo Lite).\n' >&2
  printf 'URL/search: ' >&2
  IFS= read -r input || input=
  if [[ -z $input ]]; then
    target="https://lite.duckduckgo.com/lite/"
  else
    target=$(normalize_url "$input")
  fi
else
  if [[ $1 == -* ]]; then
    exec w3m "$@"
  fi
  target=$(normalize_url "$1")
  shift
fi

printf 'w3m keys: U URL, H help, / search, q quit, Ctrl-L redraw.\n' >&2
sleep 1

exec w3m "$target" "$@"
