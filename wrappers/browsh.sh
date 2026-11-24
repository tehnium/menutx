#!/usr/bin/env bash
# browsh - a text-based web browser rendered by Firefox.
# Upstream: https://github.com/browsh-org/browsh (LGPL-2.1)
#
# With no arguments this asks for a URL or a search term, then opens
# DuckDuckGo Lite when the input is empty. Browsh uses a fixed local port
# (3334), so only one instance can run at a time.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

if ! command -v browsh >/dev/null 2>&1; then
  printf 'menutx: Browsh is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

FIREFOX=""
for candidate in "$(command -v firefox-esr 2>/dev/null || true)" \
                 "$(command -v firefox 2>/dev/null || true)"; do
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

# Do not block --version or --help on a running instance.
if (( $# )); then
  for arg in "$@"; do
    case $arg in
      --version|--help|-h)
        exec browsh --firefox.path "$FIREFOX" "$@"
        ;;
    esac
  done
fi

# Browsh always binds port 3334. A stale or second instance leaves the new
# one on its splash screen, so detect the conflict before starting.
if command -v ss >/dev/null 2>&1; then
  if ss -ltn 2>/dev/null | grep -q ':3334[[:space:]]'; then
    printf 'menutx: Browsh is already running (port 3334 is in use).\n' >&2
    printf '  Close the other Browsh window with Ctrl+Q, or run: pkill -f browsh\n' >&2
    exit 1
  fi
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
  printf 'Browsh - type a URL or a search (Enter = DuckDuckGo Lite).\n' >&2
  printf 'URL/search: ' >&2
  IFS= read -r input || input=
  if [[ -z $input ]]; then
    target="https://lite.duckduckgo.com/lite/"
  else
    target=$(normalize_url "$input")
  fi
else
  first=$1
  shift
  if [[ $first != -* ]]; then
    target=$(normalize_url "$first")
  fi
fi

printf 'Browsh keys: Ctrl+L URL bar, Ctrl+T new tab, Ctrl+Q quit.\n' >&2
sleep 1

if [[ -n $target ]]; then
  exec browsh --firefox.path "$FIREFOX" --startup-url "$target" "$@"
fi
exec browsh --firefox.path "$FIREFOX" "$@"
