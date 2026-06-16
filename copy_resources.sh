#!/usr/bin/env bash
#
# copy_resources.sh
#
# Copies the binary image assets from the original Objective-C project into
# this Swift port. The Cowork sandbox that generated the port could not copy
# binary files itself, so run this once after cloning/checkout.
#
# Usage:
#   ./copy_resources.sh [path-to-original-iOS_HappySpeedUp]
#
# If no path is given it assumes the original repo is a sibling directory:
#   ../iOS_HappySpeedUp
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${1:-$HERE/../iOS_HappySpeedUp}"
SRC_IMAGES="$SRC_ROOT/Try_HappySpeedUp/Images"
DST_IMAGES="$HERE/HappySpeedUp/Images"

if [ ! -d "$SRC_IMAGES" ]; then
  echo "error: could not find original images at: $SRC_IMAGES" >&2
  echo "       pass the path to the original iOS_HappySpeedUp repo as arg 1." >&2
  exit 1
fi

mkdir -p "$DST_IMAGES"
cp -v "$SRC_IMAGES"/* "$DST_IMAGES"/

echo ""
echo "Copied $(ls -1 "$DST_IMAGES" | wc -l | tr -d ' ') image files into HappySpeedUp/Images/"
echo "You can now build & run the HappySpeedUp scheme in Xcode."
