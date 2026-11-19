#!/usr/bin/env bash
# Prints a checksum line for every file in the kit, in a fixed order: the MANIFEST a release
# carries. Godot's own .import and .uid files, which it may rewrite, and the MANIFEST itself are
# left out.
#   cove_kit/tools/manifest.sh [kit folder]
set -euo pipefail
kit=${1:-"$(cd "$(dirname "$0")/.." && pwd)"}
cd "$kit"
find . -type f ! -name '*.import' ! -name '*.uid' ! -name MANIFEST ! -name .DS_Store \
	| sed 's#^\./##' | LC_ALL=C sort | while IFS= read -r file; do
	printf '%s  %s\n' "$(shasum -a 256 "$file" | cut -d' ' -f1)" "$file"
done
