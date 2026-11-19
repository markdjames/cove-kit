#!/usr/bin/env bash
# Replaces a game's cove_kit/ with a released version of the kit, then verifies it. Run it from
# the game's copy, or from a cove-kit checkout with the game's folder for the first time:
#   cove_kit/tools/update.sh v1.1.0
#   ~/www/cove-kit/cove_kit/tools/update.sh v1.0.0 ~/www/some-game
# COVE_KIT_REPO overrides where the kit comes from (a URL or a local checkout).
set -euo pipefail
version=${1:?"usage: update.sh <version> [game folder]"}
repo=${COVE_KIT_REPO:-https://github.com/markdjames/cove-kit.git}
here="$(cd "$(dirname "$0")/../.." && pwd)"
game="$(cd "${2:-$here}" && pwd)"
if [[ ! -f "$game/project.godot" ]]; then
	echo "$game isn't a Godot project." >&2
	exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
git clone --quiet --depth 1 --branch "$version" "$repo" "$work/kit" 2>/dev/null \
	|| { echo "No version $version in $repo." >&2; exit 1; }
# This script may be the one being replaced, so the copy runs from the new kit's files.
rsync -a --delete --exclude .DS_Store "$work/kit/cove_kit/" "$game/cove_kit/"
"$game/cove_kit/tools/verify.sh"
echo "Updated $game/cove_kit to $version. Run tools/check.sh, then commit cove_kit/."
