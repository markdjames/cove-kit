#!/usr/bin/env bash
# Fails if this copy of the kit differs from the release it came from, as recorded in MANIFEST.
# A game's tools/check.sh runs it, so the kit is only ever changed in the cove-kit repository.
#   cove_kit/tools/verify.sh
set -euo pipefail
kit="$(cd "$(dirname "$0")/.." && pwd)"
if [[ ! -f "$kit/MANIFEST" ]]; then
	echo "ERROR: $kit has no MANIFEST; take the kit with cove_kit/tools/update.sh <version>." >&2
	exit 1
fi
if ! changes=$(diff <(cat "$kit/MANIFEST") <("$kit/tools/manifest.sh" "$kit")); then
	echo "ERROR: cove_kit/ differs from cove-kit $(cat "$kit/VERSION" 2>/dev/null || echo '(no VERSION)')." >&2
	echo "Make design changes in the cove-kit repository, release them, then update with" >&2
	echo "cove_kit/tools/update.sh <version>. The differences (< release, > here):" >&2
	echo "$changes" | grep '^[<>]' | sed 's/^\([<>]\) [0-9a-f]*  /\1 /' >&2
	exit 1
fi
echo "cove-kit $(cat "$kit/VERSION") unchanged"
