extends "test_case.gd"

const GamePirate := preload("fixtures/game_pirate.gd")


func _pirate() -> Pirate:
	var pirate: Pirate = preload("res://cove_kit/pirate.tscn").instantiate()
	add_child(pirate)
	return pirate


func test_she_speaks_in_a_pose() -> void:
	var pirate := _pirate()
	assert_eq(pirate.current_pose(), Pirate.Pose.WAITING, "waits to begin with")
	assert_false(pirate.is_speaking(), "silent to begin with")
	pirate.speak(Pirate.Pose.CHEERING, "Yo-ho-ho!")
	assert_eq(pirate.current_pose(), Pirate.Pose.CHEERING, "cheers")
	assert_true(pirate.is_speaking(), "speaks")
	pirate.hush()
	assert_false(pirate.is_speaking(), "hushed")
	assert_eq(pirate.current_pose(), Pirate.Pose.CHEERING, "keeps her pose when hushed")
	pirate.free()


func test_presenting_points_without_a_word() -> void:
	var pirate := _pirate()
	pirate.speak(Pirate.Pose.WAITING, "Ahoy!")
	pirate.present(Vector2(600, 300))
	assert_eq(pirate.current_pose(), Pirate.Pose.POINTING, "points")
	assert_false(pirate.is_speaking(), "says nothing")
	pirate.free()


func test_speaking_brings_her_back_after_she_leaves() -> void:
	var pirate := _pirate()
	pirate.hide()
	pirate.speak(Pirate.Pose.WAITING, "I'm back!")
	assert_true(pirate.visible, "back on screen")
	pirate.free()


func test_a_game_gives_her_its_own_lines() -> void:
	var pirate: Pirate = preload("res://cove_kit/pirate.tscn").instantiate()
	pirate.set_script(GamePirate)
	add_child(pirate)
	pirate.call("greet")
	assert_true(pirate.is_speaking(), "speaks the game's line")
	assert_eq((pirate.get_node("Bubble/Text") as Label).text, GamePirate.GREETING, "the game's greeting")
	pirate.free()
