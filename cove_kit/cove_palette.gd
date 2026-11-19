class_name CovePalette
extends RefCounted

## The colours every Captain Emmy's Cove game draws with. A game's own `Palette` extends this and
## adds colours only it needs, so `Palette.INK` works in every game. UI styling stays in theme.tres.

const INK := Color("3b2414")
const PAPER := Color("fff4d9")
const CORAL := Color("d4513a")
const TEAL := Color("2b8c9e")
const GOLD := Color("f9b21b")
## The deep sea behind everything, and the clear colour.
const NIGHT := Color(0.09, 0.208, 0.267)
const OCEAN := Color("6aaec4")
const SHALLOWS := Color("a8dbe3")
const WAVES := Color("2f6f8ab3")
const LAND := Color("f4e4bc")
