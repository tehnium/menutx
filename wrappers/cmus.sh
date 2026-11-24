#!/usr/bin/env bash
# cmus - a music player and library for the terminal, with a directory picker.
# Upstream: https://github.com/cmus/cmus (GPL-2.0)
#
# With no arguments this opens the picker, then starts cmus and queues the
# chosen track. If cmus is already running, the track is added to that
# instance instead of starting a second one.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v cmus >/dev/null 2>&1; then
  printf 'menutx: cmus is not installed. Re-run the menutx installer.\n' >&2
  exit 127
fi

if (( $# == 0 )) && [[ -x $DIR/_pick.sh ]]; then
  picked=$("$DIR/_pick.sh" audio) || exit 0

  if command -v cmus-remote >/dev/null 2>&1; then
    if cmus-remote -Q >/dev/null 2>&1; then
      cmus-remote -C "add -q \"$picked\"" >/dev/null 2>&1
      cmus-remote -C "player-play" >/dev/null 2>&1
      printf 'Added to the running cmus instance: %s\n' "$picked"
      exit 0
    fi
    (
      for ((i = 0; i < 50; i++)); do
        cmus-remote -Q >/dev/null 2>&1 && break
        sleep 0.1
      done
      cmus-remote -C "add -q \"$picked\"" >/dev/null 2>&1
      cmus-remote -C "player-play" >/dev/null 2>&1
    ) >/dev/null 2>&1 &
  fi

  exec cmus
fi

exec cmus "$@"
