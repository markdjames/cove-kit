# Cove kit

The shared look and sound of the Captain Emmy's Cove games: the theme, fonts, colours, Captain
Emmy, her speech bubble, the shared icons and the sound palette. Each game keeps its own
repository and carries a pinned copy of `cove_kit/`, so they all look and sound alike, and a design
change is made once, here.

Built with [Godot 4.7](https://godotengine.org/). This repository is a small Godot project whose
only real content is `cove_kit/`; the preview scene and tests are for working on it.

## What's in it

| Path | What |
| --- | --- |
| `cove_kit/theme.tres` | Every style the games use (buttons, cards, banners, tags, bubbles) |
| `cove_kit/fonts/` | Andika Bold and Luckiest Guy, with their licences |
| `cove_kit/cove_palette.gd` | `CovePalette`, the shared colours; a game's `Palette` extends it |
| `cove_kit/pirate.tscn`, `pirate.gd` | `Pirate`, Captain Emmy in three poses with a bubble above her |
| `cove_kit/emmy/` | Her poses: waiting, pointing, cheering |
| `cove_kit/speech_bubble.gd` | `SpeechBubble`, with its tail pointing down or left |
| `cove_kit/icons/` | Shared UI icons and the treasure chest |
| `cove_kit/sounds/`, `sfx.gd`, `music.gd` | The sound palette, `Sfx` and `Music`; sources in `sounds/README.md` |
| `cove_kit/bus_layout.tres` | The Sfx and Music buses the players use |
| `cove_kit/tools/` | `update.sh` and `verify.sh`, which games run |

## Using it in a game

The first time, from this checkout:

```bash
~/www/cove-kit/cove_kit/tools/update.sh v1.0.0 ~/www/some-game
```

After that, from the game:

```bash
cove_kit/tools/update.sh v1.1.0
```

It replaces the game's `cove_kit/` with that release and checks it. Commit the result.

In the game:

- Set the project theme to `res://cove_kit/theme.tres`, and the bus layout to
  `res://cove_kit/bus_layout.tres` (or a layout of the game's own with the same Sfx and Music
  buses).
- Give `Palette` (`class_name Palette extends CovePalette`) only the colours that game needs.
- Instance `pirate.tscn` and set a script on it that extends `Pirate` with the game's own lines.
- Add `Sfx` and `Music` nodes to the main scene.
- Run `cove_kit/tools/verify.sh` from the game's `tools/check.sh`. It fails if anything in
  `cove_kit/` has been edited, since changes belong here.

## Changing the design

1. Change it here, and look at it in the preview: open the project in Godot and press ▶.
2. `tools/check.sh` imports the project, parses every script, runs the tests, runs the preview
   headless, and checks that the drift check still catches an edited file.
3. `tools/release_kit.sh v1.1.0` runs the checks, writes `cove_kit/VERSION` and
   `cove_kit/MANIFEST` (a checksum for every file), commits and tags. Push the commit and the tag.
4. Update each game when it's ready for the change. A renamed or removed style, colour, sound or
   method breaks games, so it takes a new major version (v2.0.0).

## Credits

Fonts: Andika by SIL International (SIL Open Font License) and Luckiest Guy by Astigmatic
(Apache License 2.0); licences in `cove_kit/fonts/`. Sounds: Kenney's packs, OpenGameArt and
BigSoundBank, all CC0; sources in `cove_kit/sounds/README.md`.
