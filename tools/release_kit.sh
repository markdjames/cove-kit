#!/usr/bin/env bash
# Releases a version of the kit: runs the checks, writes cove_kit/VERSION and cove_kit/MANIFEST,
# commits them and tags the commit. It doesn't push.
#   tools/release_kit.sh v1.1.0
set -euo pipefail
cd "$(dirname "$0")/.."
version=${1:?"usage: tools/release_kit.sh <version>, such as v1.1.0"}
if [[ ! $version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "A version looks like v1.2.0." >&2
	exit 1
fi
if [[ -n $(git status --porcelain) ]]; then
	echo "Commit or set aside your changes first." >&2
	exit 1
fi
if git rev-parse -q --verify "refs/tags/$version" > /dev/null; then
	echo "$version already exists." >&2
	exit 1
fi

tools/check.sh
echo "$version" > cove_kit/VERSION
cove_kit/tools/manifest.sh > cove_kit/MANIFEST
git add cove_kit/VERSION cove_kit/MANIFEST
git commit -q -m "Release $version"
git tag -a "$version" -m "Cove kit $version"
echo "Tagged $version. Push with: git push origin main $version"
