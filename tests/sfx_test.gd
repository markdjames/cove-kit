extends "test_case.gd"


func test_every_sound_file_loads() -> void:
	for sound: StringName in Sfx.SOUNDS:
		assert_false(Sfx.SOUNDS[sound].is_empty(), "%s has no files" % sound)
		for file: String in Sfx.SOUNDS[sound]:
			assert_true(load(Sfx.path_of(file)) is AudioStream, "%s doesn't load as a sound" % Sfx.path_of(file))


func test_the_sfx_bus_exists_and_mutes() -> void:
	assert_true(AudioServer.get_bus_index(Sfx.BUS) >= 0, "no %s bus in the bus layout" % Sfx.BUS)
	var was_muted := Sfx.is_muted()
	Sfx.set_muted(true)
	assert_true(Sfx.is_muted(), "muting")
	Sfx.set_muted(false)
	assert_false(Sfx.is_muted(), "unmuting")
	Sfx.set_muted(was_muted)


func test_buttons_click_once_the_sfx_node_is_in_the_tree() -> void:
	var before := Button.new()
	add_child(before)
	var sfx := Sfx.new()
	add_child(sfx)
	var after := Button.new()
	add_child(after)
	assert_true(before.pressed.get_connections().size() == 1, "a button already in the tree clicks")
	assert_true(after.pressed.get_connections().size() == 1, "a button added later clicks")
	for node: Node in [before, sfx, after]:
		node.free()


func test_a_steady_sound_plays_its_first_file_at_the_exact_pitch() -> void:
	var sfx := Sfx.new()
	add_child(sfx)
	var first: AudioStream = load(Sfx.path_of(Sfx.SOUNDS[&"tally"][0]))
	for i in Sfx.VOICES:
		Sfx.play(&"tally", 1.25, false)
	for voice: AudioStreamPlayer in sfx.find_children("*", "AudioStreamPlayer", false, false):
		assert_true(voice.stream == first, "a steady tally always plays the same file")
		assert_true(is_equal_approx(voice.pitch_scale, 1.25), "a steady tally isn't pitched at random")
	sfx.free()
