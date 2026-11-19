# Cove kit: notes for working in this repo

The shared design of the Captain Emmy's Cove games (theme, fonts, colours, Emmy, speech bubble,
icons, sounds). Games copy `cove_kit/` at a released version; the README says how. Map Hunt
(`~/www/geo-game`) is the first game to use it, and its `docs/decisions.md` ("Cove games share a
design kit") records why the kit exists.

- Run `tools/check.sh` after any change. Godot is at `/Applications/Godot.app/Contents/MacOS/Godot`.
- Everything under `cove_kit/` must use `res://cove_kit/` paths, since games carry it at that path.
- Keep the kit to design. Game logic, a game's own lines for Emmy and its map or audio engines stay
  in the game.
- A change that renames or removes anything a game uses (a theme style, a colour, a sound, a
  method) breaks games: say so, and release it as a new major version.
- `tests/theme_test.gd` lists the styles the games set by name. Add to it when a game starts using
  another.
- Release with `tools/release_kit.sh <version>` only when the user asks. It commits and tags but
  doesn't push.
- Same conventions as Map Hunt: tabs, static types, `class_name` on reusable scripts, comments only
  where intent isn't obvious, warnings for shadowed and unused names are errors.
