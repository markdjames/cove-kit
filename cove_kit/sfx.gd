class_name Sfx
extends Node

## Sound effects and haptics. A game puts an Sfx node in its main scene to own the players; the
## rest of the game calls the static functions, which do nothing without it (in tests, say). Every
## button in the tree clicks when pressed.

const BUS := &"Sfx"
## Files in cove_kit/sounds/ for each sound, one picked at random each time it plays.
const SOUNDS := {
	&"found": ["found"],
	&"tally": ["tally_1", "tally_2", "tally_3"],
	&"miss": ["miss"],
	&"closer": ["closer"],
	&"click": ["click"],
	&"haul": ["haul"],
	&"chin_up": ["chin_up"],
}
## Enough for the results card's tally, whose sounds overlap.
const VOICES := 6
## Each sound plays a little higher or lower at random, so repeats don't sound mechanical.
const PITCH_SPREAD := 0.05
const BUZZ_MS := 40
const BUZZ_STRENGTH := 0.5
const GROUP := &"sfx"

var _streams: Dictionary[StringName, Array] = {}
var _voices: Array[AudioStreamPlayer] = []
var _next_voice := 0


## Without `vary`, the sound plays its first file at exactly `pitch`, for runs that should rise
## steadily, like the results card's tally.
static func play(sound: StringName, pitch := 1.0, vary := true) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	# Not cast to Sfx: a script naming its own class leaks at exit when check.sh only parses it.
	var sfx: Node = tree.get_first_node_in_group(GROUP) if tree else null
	if sfx:
		sfx._play(sound, pitch, vary)


static func path_of(file: String) -> String:
	return "res://cove_kit/sounds/%s.ogg" % file


## The length of the sound's first file, in seconds.
static func length_of(sound: StringName) -> float:
	var stream: AudioStream = load(path_of(SOUNDS[sound][0]))
	return stream.get_length()


static func buzz() -> void:
	Input.vibrate_handheld(BUZZ_MS, BUZZ_STRENGTH)


static func set_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS), muted)


static func is_muted() -> bool:
	return AudioServer.is_bus_mute(AudioServer.get_bus_index(BUS))


func _ready() -> void:
	add_to_group(GROUP)
	for sound: StringName in SOUNDS:
		_streams[sound] = SOUNDS[sound].map(func(file: String) -> AudioStream: return load(path_of(file)))
	for i in VOICES:
		var voice := AudioStreamPlayer.new()
		voice.bus = BUS
		add_child(voice)
		_voices.append(voice)
	for button in get_tree().root.find_children("*", "BaseButton", true, false):
		_click_when_pressed(button)
	get_tree().node_added.connect(_click_when_pressed)


func _play(sound: StringName, pitch: float, vary: bool) -> void:
	var voice := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % VOICES
	if vary:
		voice.stream = _streams[sound].pick_random()
		voice.pitch_scale = pitch * randf_range(1.0 - PITCH_SPREAD, 1.0 + PITCH_SPREAD)
	else:
		voice.stream = _streams[sound][0]
		voice.pitch_scale = pitch
	voice.play()


func _click_when_pressed(node: Node) -> void:
	if node is BaseButton:
		(node as BaseButton).pressed.connect(play.bind(&"click"))
