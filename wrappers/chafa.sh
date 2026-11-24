#!/usr/bin/env bash
# chafa - image and GIF viewer for the terminal, with a directory picker.
# Upstream: https://github.com/hpjansson/chafa (LGPL-3.0)
#
# The default symbols mode works in every terminal. Use -f kitty or -f sixels
# for higher quality in terminals that support those protocols.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v chafa >/dev/null 2>&1; then
  printf 'menutx: chafa is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

args=("$@")

if (( ${#args[@]} == 0 )); then
  if [[ ! -x $DIR/_pick.sh ]]; then
    printf 'Usage: %s IMAGE\n' "${0##*/}" >&2
    exit 2
  fi
  picked=$("$DIR/_pick.sh" image) || exit 0
  args=("$picked")
fi

exec chafa "${args[@]}"
