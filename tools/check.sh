#!/usr/bin/env bash
# Re-imports the project, parses every script, runs the tests, runs the preview headless for a
# second, and checks the kit's manifest scripts catch an edited file. Fails on any engine error.
set -euo pipefail
cd "$(dirname "$0")/.."

GODOT=${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}

output=$("$GODOT" --headless --editor --quit --path . 2>&1) || true
output+=$'\n'$("$GODOT" --headless --path . --script res://tools/load_scripts.gd 2>&1) || true
if grep -E "ERROR" <<<"$output"; then
	exit 1
fi

if ! tests=$("$GODOT" --headless --path . --script res://tests/run_tests.gd 2>&1); then
	echo "$tests"
	exit 1
fi
output+=$'\n'$tests
# The shanty plays from the first frame, and Godot reports a stream still playing at quit as
# leaked resources, so that one message is ignored.
output+=$'\n'$("$GODOT" --headless --path . --quit-after 60 2>&1 | grep -v "resources still in use at exit")
if grep -E "ERROR" <<<"$output"; then
	exit 1
fi

# The drift check, on a scratch copy: it passes as released and fails once a file is edited.
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
cp -R cove_kit "$scratch/cove_kit"
echo "check" > "$scratch/cove_kit/VERSION"
cove_kit/tools/manifest.sh "$scratch/cove_kit" > "$scratch/cove_kit/MANIFEST"
"$scratch/cove_kit/tools/verify.sh" > /dev/null
echo "edited" >> "$scratch/cove_kit/theme.tres"
if "$scratch/cove_kit/tools/verify.sh" > /dev/null 2>&1; then
	echo "ERROR: verify.sh didn't notice an edited theme.tres"
	exit 1
fi

echo "$(tail -n 1 <<<"$tests")"
echo "OK"
