extends "test_case.gd"


func test_every_track_loads() -> void:
	for track: StringName in Music.TRACKS:
		assert_true(load(Music.path_of(track)) is AudioStream, "%s doesn't load as a sound" % Music.path_of(track))


func test_the_music_bus_exists_and_mutes_apart_from_the_effects() -> void:
	assert_true(AudioServer.get_bus_index(Music.BUS) >= 0, "no %s bus in the bus layout" % Music.BUS)
	var was_muted := Music.is_muted()
	var sfx_was_muted := Sfx.is_muted()
	Sfx.set_muted(false)
	Music.set_muted(true)
	assert_true(Music.is_muted(), "muting")
	assert_false(Sfx.is_muted(), "muting the music leaves the effects on")
	Music.set_muted(false)
	assert_false(Music.is_muted(), "unmuting")
	Music.set_muted(was_muted)
	Sfx.set_muted(sfx_was_muted)


func test_a_seam_neither_dips_nor_swells() -> void:
	var length := 60.0
	var seam := 4.0
	for step in 9:
		var into_seam := seam * step / 8.0
		var ending := Music.SeamLoop.seam_gain(length - seam + into_seam, length, seam)
		var starting := Music.SeamLoop.seam_gain(into_seam, length, seam)
		assert_near(ending * ending + starting * starting, 1.0, 0.001, "power %.1f s into the seam" % into_seam)
	assert_near(Music.SeamLoop.seam_gain(length / 2.0, length, seam), 1.0, 0.001, "full volume between seams")
	assert_near(Music.SeamLoop.seam_gain(10.0, length, 0.0), 1.0, 0.001, "full volume with no seam")


func test_only_the_track_asked_for_plays() -> void:
	var music := Music.new()
	add_child(music)
	Music.play(&"sea")
	var playing: Array[String] = []
	for player: AudioStreamPlayer in music.find_children("*", "AudioStreamPlayer", true, false):
		if player.playing:
			playing.append(player.stream.resource_path)
	assert_eq(playing, [Music.path_of(&"sea")] as Array[String], "players started")
	music.free()


func test_the_music_fades_back_in_when_the_game_resumes() -> void:
	var music := Music.new()
	add_child(music)
	var shanty: Music.SeamLoop = music._loops[&"shanty"]
	shanty._resume()
	shanty._set_level(1.0)
	var full: float = Music.TRACKS[&"shanty"]["volume_db"]
	assert_near(shanty.lead_volume_db(), full, 0.01, "full volume before pausing")
	music.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert_near(shanty.lead_volume_db(), Music.TRACKS[&"shanty"]["volume_db"] + linear_to_db(Music.SILENT), 0.01, "silent while paused")
	music.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	assert_true(shanty.lead_volume_db() < full - 40.0, "still quiet just after resuming")
	music._set_wake(0.5)
	assert_true(shanty.lead_volume_db() < full and shanty.lead_volume_db() > full - 40.0, "partway up")
	music._wake.custom_step(Music.WAKE + 0.1)
	assert_near(shanty.lead_volume_db(), full, 0.01, "back to full once the fade ends")
	music.free()
