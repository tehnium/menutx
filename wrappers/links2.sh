#!/usr/bin/env bash
# links2 - a text web browser with tables, forms, cookies and SSL.
# Upstream: http://links.twibright.com/ (GPL-2.0)
#
# Keys: g = URL, Esc = menu, / = search in the page, q = quit.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v links2 >/dev/null 2>&1; then
  printf 'menutx: links2 is not installed.\n' >&2
  printf '  Install it with: sudo apt install links2\n' >&2
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
  printf 'links2 - type a URL or a search (Enter = DuckDuckGo Lite).\n' >&2
  printf 'URL/search: ' >&2
  IFS= read -r input || input=
  if [[ -z $input ]]; then
    target="https://lite.duckduckgo.com/lite/"
  else
    target=$(normalize_url "$input")
  fi
else
  if [[ $1 == -* ]]; then
    exec links2 "$@"
  fi
  target=$(normalize_url "$1")
  shift
fi

printf 'links2 keys: g URL, Esc menu, / search, q quit.\n' >&2
sleep 1

exec links2 "$target" "$@"
