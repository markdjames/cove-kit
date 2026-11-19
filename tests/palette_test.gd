extends "test_case.gd"

const GamePalette := preload("fixtures/game_palette.gd")


func test_a_game_palette_keeps_the_kit_colours_and_adds_its_own() -> void:
	assert_eq(GamePalette.INK, CovePalette.INK, "ink, through a game's palette")
	assert_eq(GamePalette.NIGHT, CovePalette.NIGHT, "night, through a game's palette")
	assert_eq(GamePalette.BORDER, Color("9c7a4e"), "the game's own colour")


func test_night_is_the_clear_colour() -> void:
	var clear: Color = ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color")
	assert_true(clear.is_equal_approx(CovePalette.NIGHT), "the clear colour is night")
