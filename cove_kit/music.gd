class_name Music
extends Node

## Background sound: a shanty behind the menu card and the sea during a round, on a bus of their
## own so they can be switched off apart from the effects. A game puts a Music node in its main
## scene to own the players; the rest of the game calls the static functions, which do nothing
## without it.

const BUS := &"Music"
const GROUP := &"music"
## Each track's file in cove_kit/sounds/, how loud it plays, and for a recording that doesn't
## loop cleanly, how many seconds its end overlaps its start.
const TRACKS := {
	&"shanty": {"file": "shanty", "volume_db": -8.0, "seam": 0.0},
	&"sea": {"file": "sea", "volume_db": -18.0, "seam": 4.0},
}
## Seconds for one track to fade out as the next fades in.
const CHANGE := 1.5
## The music dips under the results card's tally and jingle.
const DUCK_DB := -14.0
const DUCK_FADE := 0.25
## Seconds the music takes to fade back in when the game comes back from the background. Android
## pauses the audio mid-note, so without it the track would jump straight back in at full volume.
const WAKE := 2.0
## The quietest gain a player is set to, since linear_to_db(0.0) is -inf.
const SILENT := 0.001

var _loops: Dictionary[StringName, SeamLoop] = {}
var _current := &""
var _duck: Tween
var _wake: Tween


static func play(track: StringName, fade := CHANGE) -> void:
	var music := _node()
	if music:
		music._play(track, fade)


## Dips the music for `seconds`, then brings it back.
static func duck(seconds: float) -> void:
	var music := _node()
	if music:
		music._duck_for(seconds)


static func set_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS), muted)


static func is_muted() -> bool:
	return AudioServer.is_bus_mute(AudioServer.get_bus_index(BUS))


static func path_of(track: StringName) -> String:
	return Sfx.path_of(TRACKS[track]["file"])


# Not typed as Music: a script naming its own class leaks at exit when check.sh only parses it.
static func _node() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.get_first_node_in_group(GROUP) if tree else null


func _ready() -> void:
	add_to_group(GROUP)
	for track: StringName in TRACKS:
		var loop := SeamLoop.new(load(path_of(track)), TRACKS[track]["volume_db"], TRACKS[track]["seam"])
		add_child(loop)
		_loops[track] = loop


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		_set_wake(0.0)
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		wake_up(WAKE)


## Fades every track in from silence over `seconds`, as when the game returns from the background.
func wake_up(seconds: float) -> void:
	if _wake:
		_wake.kill()
	_set_wake(0.0)
	_wake = create_tween()
	_wake.tween_method(_set_wake, 0.0, 1.0, seconds).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)


func _set_wake(gain: float) -> void:
	for loop: SeamLoop in _loops.values():
		loop.set_wake(gain)


func _play(track: StringName, fade: float) -> void:
	if track == _current:
		return
	_current = track
	_set_duck(0.0)
	for each: StringName in _loops:
		_loops[each].fade_to(1.0 if each == track else 0.0, fade)


func _duck_for(seconds: float) -> void:
	_set_duck(DUCK_DB)
	_duck.tween_interval(seconds)
	_duck.tween_method(_set_bus_volume, DUCK_DB, 0.0, DUCK_FADE)


func _set_duck(to_db: float) -> void:
	if _duck:
		_duck.kill()
	_duck = create_tween()
	_duck.tween_method(_set_bus_volume, AudioServer.get_bus_volume_db(AudioServer.get_bus_index(BUS)), to_db, DUCK_FADE)


func _set_bus_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS), db)


## One track. With a seam, two players take turns: each starts as the other nears its end. A
## track that has faded out pauses, and picks up where it left off when it comes back.
class SeamLoop:
	extends Node

	var _players: Array[AudioStreamPlayer] = []
	var _lead := 0
	var _length: float
	var _seam: float
	var _volume_db: float
	var _level := 0.0
	var _wake := 1.0
	var _fade: Tween

	## How loud a seamed loop plays `position` seconds in: rising over the first `seam` seconds and
	## falling over the last, on curves whose powers sum to one where the end overlaps the next start,
	## so the seam neither dips nor swells.
	static func seam_gain(position: float, length: float, seam: float) -> float:
		if seam <= 0.0:
			return 1.0
		var rise := clampf(position / seam, 0.0, 1.0)
		var fall := clampf((length - position) / seam, 0.0, 1.0)
		return sin(rise * PI / 2.0) * sin(fall * PI / 2.0)

	func _init(stream: AudioStream, volume_db: float, seam: float) -> void:
		_length = stream.get_length()
		_seam = seam
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = seam <= 0.0
		_volume_db = volume_db
		for i in 2 if seam > 0.0 else 1:
			var player := AudioStreamPlayer.new()
			player.stream = stream
			player.bus = BUS
			add_child(player)
			_players.append(player)
		set_process(false)

	func fade_to(level: float, seconds: float) -> void:
		if _fade:
			_fade.kill()
		if level > 0.0:
			_resume()
		_fade = create_tween()
		_fade.tween_method(_set_level, _level, level, seconds)
		if level <= 0.0:
			_fade.tween_callback(_pause)

	## Scales the track's volume, apart from its own fades, while the game wakes up.
	func set_wake(gain: float) -> void:
		_wake = gain
		_apply_volume()

	func lead_volume_db() -> float:
		return _players[_lead].volume_db

	func _set_level(level: float) -> void:
		_level = level
		_apply_volume()

	func _resume() -> void:
		set_process(true)
		var lead := _players[_lead]
		if lead.stream_paused:
			for player in _players:
				player.stream_paused = false
		elif not lead.playing:
			lead.play()

	func _pause() -> void:
		set_process(false)
		for player in _players:
			player.stream_paused = true

	func _process(_delta: float) -> void:
		if _seam > 0.0 and _players[_lead].get_playback_position() >= _length - _seam:
			_lead = 1 - _lead
			_players[_lead].play()
		_apply_volume()

	func _apply_volume() -> void:
		for player in _players:
			var gain := _level * _wake * seam_gain(player.get_playback_position(), _length, _seam) if player.playing else 0.0
			player.volume_db = _volume_db + linear_to_db(maxf(gain, SILENT))
