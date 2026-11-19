# Sounds

Effects from three of Kenney's packs, all CC0 (licences beside this file), renamed for what they do
in the game. To try another sound, copy it over the file here.

| File | Plays when | Source |
|---|---|---|
| `found.ogg` | a right answer | Interface Sounds, `confirmation_001.ogg` |
| `tally_1.ogg` to `tally_3.ogg` | a coin lands in the score, or on the results card | Casino Audio, `chip-lay-1.ogg` to `chip-lay-3.ogg` |
| `miss.ogg` | a miss | Interface Sounds, `bong_001.ogg` |
| `closer.ogg` | a close call zooms in | Interface Sounds, `question_001.ogg` |
| `click.ogg` | any button | Interface Sounds, `click_001.ogg` |
| `haul.ogg` | the end of the results card's tally, for 8 or more out of 10 | Music Jingles, `jingles_STEEL10.ogg` |
| `chin_up.ogg` | the end of the results card's tally, for fewer than 5 out of 10 | Music Jingles, `jingles_STEEL07.ogg` |

## Music

Played by `Music` (cove_kit/music.gd) on the Music bus, which the music button mutes. Both are CC0.

| File | Plays when | Source |
|---|---|---|
| `shanty.ogg` | the menu card is up | [A sailor's chant](https://opengameart.org/content/a-sailors-chant) by Thimras, OpenGameArt, `oga_jam_menu_music_loopable.ogg`, cut to its first 40.85 s |
| `sea.ogg` | a round or a round review | [Sea waves and seagulls](https://bigsoundbank.com/sea-waves-and-seagulls-s0267.html) by Denis Chardonnet, BigSoundBank #0267 |

`shanty.ogg` is the first 48 of the original's 80 beats, which ends in the pause before the vocal.
The cut is exactly on the beat, so it loops by itself; its last 10 ms are blended into the
original's last 10 ms, which already ran on into its start. Re-encoded with `oggenc -q 5`.
`sea.ogg` doesn't loop cleanly, so `Music` overlaps its last four seconds with its start.
