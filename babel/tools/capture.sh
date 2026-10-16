#!/usr/bin/env bash
# Capture frames of a scene with Godot's Movie Maker so they can be inspected (ENG-011).
#
# Usage (from anywhere):
#   babel/tools/capture.sh <scene> [frames] [outdir]
#     scene   res:// path, e.g. res://tests/visual/pixel_perfect.tscn
#     frames  frames to render at a fixed 60 fps (default 120)
#     outdir  output folder (default <repo>/build/captures/<scene name>)
#
# Writes f00000000.png ... at the native 640x360 plus godot.log, prints any lines the
# scene logged with a "VISUAL" prefix, then prints the path of the last frame.
# Movie Maker renders for real, so this opens a window: it cannot run with --headless.
set -euo pipefail

scene="${1:?usage: capture.sh <res://scene.tscn> [frames] [outdir]}"
frames="${2:-120}"
tools_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && (pwd -W 2>/dev/null || pwd))"
project="$(dirname "$tools_dir")"
repo="$(dirname "$project")"
outdir="${3:-$repo/build/captures/$(basename "$scene" .tscn)}"

mkdir -p "$outdir"
rm -f "$outdir"/f*.png "$outdir"/f.wav "$outdir"/godot.log

# The capture window never takes focus (display/window/size/no_focus, set through an
# override.cfg that only exists during the run). Losing focus makes Godot release every
# held action, which broke tests whenever something else on the desktop took focus, and
# a window that can't be focused also leaves your editor's focus alone.
override="$project/override.cfg"
if [[ ! -e "$override" ]]; then
	printf '[display]

window/size/no_focus=true
' >"$override"
	trap 'rm -f "$override"' EXIT
fi

if ! godot --path "$project" --write-movie "$outdir/f.png" --fixed-fps 60 \
		--quit-after "$frames" --scene "$scene" >"$outdir/godot.log" 2>&1; then
	cat "$outdir/godot.log" >&2
	exit 1
fi
rm -f "$outdir/f.wav"

grep -E "^VISUAL|ERROR|SCRIPT ERROR" "$outdir/godot.log" || true
printf "%s/f%08d.png\n" "$outdir" $((frames - 1))
