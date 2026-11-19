extends Control
## Everything in the kit on one screen, to check a change by eye before releasing it: the theme's
## styles, the colours, the icons, Emmy in each pose, both bubble tails, and every sound.

const SWATCHES: Array[StringName] = [
	&"INK", &"PAPER", &"CORAL", &"TEAL", &"GOLD", &"NIGHT", &"OCEAN", &"SHALLOWS", &"WAVES", &"LAND",
]
const ICONS: Array[String] = [
	"back", "close", "home", "next", "settings", "sound_on", "sound_off", "music_on", "music_off",
	"star", "zoom_in", "zoom_out", "chest",
]
const LINES := {
	Pirate.Pose.WAITING: "Ahoy! This is the Cove kit.",
	Pirate.Pose.POINTING: "Every game takes its look from here.",
	Pirate.Pose.CHEERING: "Shiver me timbers, it all matches!",
}
const POSE_SECONDS := 3.0
const CARD_WIDTH := 440.0

@onready var _pirate: Pirate = $Pirate

var _pose_index := 0


func _ready() -> void:
	var page := HBoxContainer.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.offset_left = 340.0
	page.offset_top = 24.0
	page.offset_right = -24.0
	page.offset_bottom = -24.0
	page.add_theme_constant_override("separation", 24)
	add_child(page)
	page.add_child(_card_column())
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.add_child(_kit_column())
	page.add_child(scroll)
	move_child(_pirate, -1)
	_next_pose()
	var timer := Timer.new()
	timer.wait_time = POSE_SECONDS
	timer.autostart = true
	timer.timeout.connect(_next_pose)
	add_child(timer)
	Music.play(&"shanty")


func _card_column() -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size.x = CARD_WIDTH
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	card.add_child(column)
	column.add_child(_label(&"TitleLabel", "Cove kit"))
	column.add_child(_label(&"Subtitle", "Styles, colours, icons, sounds"))
	for variation: StringName in [&"PrimaryButton", &"ModeButton"]:
		var button := Button.new()
		button.theme_type_variation = variation
		button.text = String(variation)
		column.add_child(button)
	var banner := PanelContainer.new()
	banner.theme_type_variation = &"Banner"
	var prompt := HBoxContainer.new()
	prompt.add_child(_label(&"PromptLead", "Find"))
	prompt.add_child(_label(&"PromptText", "the treasure"))
	banner.add_child(prompt)
	column.add_child(banner)
	var bubble := SpeechBubble.new()
	bubble.tail = SpeechBubble.Tail.LEFT
	bubble.tail_length = 26.0
	var holder := MarginContainer.new()
	holder.add_theme_constant_override("margin_left", 30)
	holder.add_child(bubble)
	column.add_child(holder)
	bubble.say.call_deferred("A bubble with its tail to the left")
	column.add_child(_label(&"SmallText", "SmallText: the fine print"))
	return card


func _kit_column() -> Control:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 16)
	var pill := PanelContainer.new()
	pill.theme_type_variation = &"Pill"
	pill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var score := HBoxContainer.new()
	score.add_child(_icon("chest"))
	score.add_child(_label(&"ScoreNumber", "24"))
	pill.add_child(score)
	column.add_child(pill)
	var swatches := GridContainer.new()
	swatches.columns = 5
	var colours := (load("res://cove_kit/cove_palette.gd") as GDScript).get_script_constant_map()
	for name_of: StringName in SWATCHES:
		var swatch := ColorRect.new()
		swatch.color = colours[name_of]
		swatch.custom_minimum_size = Vector2(56, 40)
		swatch.tooltip_text = String(name_of)
		swatches.add_child(swatch)
	column.add_child(swatches)
	var icons := GridContainer.new()
	icons.columns = 4
	for icon in ICONS:
		var button := Button.new()
		button.theme_type_variation = &"RoundButton"
		button.icon = _icon_texture(icon)
		button.tooltip_text = icon
		icons.add_child(button)
	column.add_child(icons)
	var sounds := GridContainer.new()
	sounds.columns = 2
	for sound: StringName in Sfx.SOUNDS:
		var button := Button.new()
		button.theme_type_variation = &"HuntButton"
		button.text = String(sound)
		button.pressed.connect(func() -> void: Sfx.play(sound))
		sounds.add_child(button)
	for track: StringName in Music.TRACKS:
		var button := Button.new()
		button.theme_type_variation = &"HuntButton"
		button.text = "♪ " + String(track)
		button.pressed.connect(func() -> void: Music.play(track))
		sounds.add_child(button)
	column.add_child(sounds)
	return column


func _next_pose() -> void:
	var pose: Pirate.Pose = LINES.keys()[_pose_index % LINES.size()]
	_pirate.speak(pose, LINES[pose])
	if pose == Pirate.Pose.CHEERING:
		_pirate.hop_for_joy()
	_pose_index += 1


func _label(variation: StringName, text: String) -> Label:
	var label := Label.new()
	label.theme_type_variation = variation
	label.text = text
	return label


func _icon(icon: String) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = _icon_texture(icon)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.custom_minimum_size = Vector2(48, 48)
	return rect


func _icon_texture(icon: String) -> Texture2D:
	return load("res://cove_kit/icons/%s.svg" % icon)
