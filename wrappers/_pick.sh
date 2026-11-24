#!/usr/bin/env bash
# _pick.sh - shared file picker for the menutx launchers.
#
# Usage: _pick.sh KIND [START_DIR]
#   KIND is video, audio, image, text or any.
# Prints the selected absolute path and exits 0; exits 1 when cancelled.
# Uses fzf when available, otherwise a numbered directory browser.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -u

kind=${1:-any}
start=${2:-}

case $kind in
  video) exts=(mp4 mkv webm avi mov m4v mpg mpeg ogv ts flv) ;;
  audio) exts=(mp3 flac ogg opus wav m4a aac wma ape alac) ;;
  image) exts=(png jpg jpeg gif webp bmp tif tiff avif svg qoi) ;;
  text)  exts=(md markdown txt org rst tex html htm css js ts py sh json yaml yml toml ini conf cfg csv xml log) ;;
  any)   exts=() ;;
  *)
    printf '_pick.sh: unknown kind: %s\n' "$kind" >&2
    exit 2
    ;;
esac

if [[ -z $start ]]; then
  case $kind in
    video) start="$HOME/Videos" ;;
    audio) start="$HOME/Music" ;;
    image) start="$HOME/Pictures" ;;
    text)  start="$HOME/Documents" ;;
    *)     start="$HOME" ;;
  esac
fi
[[ -d $start ]] || start="$HOME"
dir=$(cd -- "$start" 2>/dev/null && pwd) || dir="$HOME"

matches_ext() {
  local name=$1 ext e
  [[ $name == *.* ]] || return 1
  ext=${name##*.}
  ext=${ext,,}
  for e in "${exts[@]}"; do
    [[ $ext == "$e" ]] && return 0
  done
  return 1
}

list_entries() {
  local d=$1 name
  printf '%s\t%s\n' "$(dirname -- "$d")" "../"
  while IFS= read -r name; do
    printf '%s\t%s\n' "$d/$name" "$name/"
  done < <(find "$d" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf '%f\n' 2>/dev/null | LC_ALL=C sort)
  while IFS= read -r name; do
    if (( ${#exts[@]} == 0 )) || matches_ext "$name"; then
      printf '%s\t%s\n' "$d/$name" "$name"
    fi
  done < <(find "$d" -mindepth 1 -maxdepth 1 -type f ! -name '.*' -printf '%f\n' 2>/dev/null | LC_ALL=C sort)
}

# fzf: a searchable directory browser. The selected path is printed on stdout;
# the UI is drawn by fzf on the terminal.
if command -v fzf >/dev/null 2>&1; then
  while :; do
    sel=$(list_entries "$dir" | fzf --delimiter=$'\t' --with-nth=2 \
      --prompt="$dir> " --height=80% --reverse \
      --header='Enter: open   Esc: cancel' || true)
    [[ -n $sel ]] || exit 1
    path=${sel%%$'\t'*}
    if [[ -d $path ]]; then
      dir=$(cd -- "$path" 2>/dev/null && pwd) || exit 1
      continue
    fi
    printf '%s\n' "$path"
    exit 0
  done
fi

# No fzf: numbered fallback. The menu goes to stderr so command substitution
# captures only the selected path.
while :; do
  mapfile -t lines < <(list_entries "$dir")
  printf '\n  %s\n' "$dir" >&2
  i=1
  for line in "${lines[@]}"; do
    printf '  %2d) %s\n' "$i" "${line#*$'\t'}" >&2
    i=$((i + 1))
  done
  printf '   0) Cancel\n' >&2
  printf 'Choose: ' >&2
  read -r choice || exit 1
  case $choice in
    0) exit 1 ;;
    ''|*[!0-9]*) continue ;;
  esac
  idx=$((choice - 1))
  if (( idx < 0 || idx >= ${#lines[@]} )); then
    continue
  fi
  line=${lines[$idx]}
  path=${line%%$'\t'*}
  if [[ -d $path ]]; then
    dir=$(cd -- "$path" 2>/dev/null && pwd) || exit 1
    continue
  fi
  printf '%s\n' "$path"
  exit 0
done
