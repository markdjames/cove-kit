extends "test_case.gd"


func _bubble_in_code(tail: SpeechBubble.Tail) -> SpeechBubble:
	var bubble := SpeechBubble.new()
	bubble.tail = tail
	add_child(bubble)
	return bubble


func test_a_bubble_made_in_code_starts_hidden_and_shows_when_it_speaks() -> void:
	var bubble := _bubble_in_code(SpeechBubble.Tail.LEFT)
	assert_false(bubble.visible, "hidden before it says anything")
	bubble.say("Ahoy!")
	assert_true(bubble.visible, "shown once it speaks")
	bubble.free()


func test_a_long_line_wraps_at_the_bubble_width() -> void:
	var bubble := _bubble_in_code(SpeechBubble.Tail.DOWN)
	bubble.max_text_width = 200.0
	bubble.say("A line far too long to sit on one row of a bubble only two hundred pixels wide")
	var label := bubble.get_child(0) as Label
	assert_eq(label.autowrap_mode, TextServer.AUTOWRAP_WORD_SMART, "wraps")
	assert_eq(label.custom_minimum_size.x, 200.0, "at the bubble's width")
	bubble.say("Short")
	assert_eq(label.autowrap_mode, TextServer.AUTOWRAP_OFF, "a short line doesn't wrap")
	bubble.free()


func test_a_bubble_in_a_scene_uses_its_text_child() -> void:
	var pirate: Pirate = preload("res://cove_kit/pirate.tscn").instantiate()
	add_child(pirate)
	var bubble := pirate.get_node("Bubble") as SpeechBubble
	assert_eq(bubble.get_child_count(), 1, "no second label made")
	bubble.say("Ahoy!")
	assert_eq((pirate.get_node("Bubble/Text") as Label).text, "Ahoy!", "speaks through its Text")
	pirate.free()
