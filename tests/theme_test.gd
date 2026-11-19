extends "test_case.gd"

const THEME := preload("res://cove_kit/theme.tres")
## Styles the games set by name, so renaming or dropping one breaks a game.
const USED_BY_GAMES: Array[StringName] = [
	&"AnswerTag", &"AnswerTagText", &"Banner", &"CloseButton", &"CreditsText", &"FactCard",
	&"FactCredit", &"FactText", &"FactTitle", &"HuntButton", &"LevelButton", &"LineTag",
	&"LineTagText", &"ModeButton", &"NewBest", &"NoteLetter", &"Pill", &"PrimaryButton",
	&"PromptLead", &"PromptText", &"RoundButton", &"ScoreNumber", &"ScrollRoll", &"SmallText",
	&"SpeechBubble", &"SpeechBubbleText", &"Subtitle", &"TitleLabel",
]


func test_every_style_the_games_use_is_there() -> void:
	var types := THEME.get_type_list()
	for type in USED_BY_GAMES:
		assert_true(type in types, "the theme has no %s" % type)


func test_the_theme_is_the_project_theme() -> void:
	assert_eq(ProjectSettings.get_setting("gui/theme/custom"), THEME.resource_path, "project theme")


func test_the_fonts_load_with_their_licences() -> void:
	for font: String in ["Andika-Bold.ttf", "LuckiestGuy-Regular.ttf"]:
		assert_true(load("res://cove_kit/fonts/" + font) is FontFile, "%s loads" % font)
	for licence: String in ["Andika-OFL.txt", "LuckiestGuy-LICENSE.txt"]:
		assert_true(FileAccess.file_exists("res://cove_kit/fonts/" + licence), "%s is there" % licence)
