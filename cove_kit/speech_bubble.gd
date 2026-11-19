class_name SpeechBubble
extends PanelContainer

## A paper speech bubble with a tail pointing at whoever is speaking: down from its bottom left, or
## out of its left side. It pops in when it says something new. It uses its Text child if it has
## one (as in main.tscn), or makes its own when built in code.

enum Tail { DOWN, LEFT }

## For a tail pointing down: where it meets the bubble, from the left edge, and how wide it is there.
const TAIL_X := 40.0
const TAIL_WIDTH := 34.0
## For a tail pointing left: where it meets the bubble, up from the bottom edge, and how tall it is.
const TAIL_Y := 26.0
const TAIL_HEIGHT := 30.0
const TAIL_LINE := 4.0
const POP_SCALE := 0.6
const POP_DURATION := 0.25

@export var tail := Tail.DOWN
@export var max_text_width := 300.0
## How far the tail reaches out from the bubble.
@export var tail_length := 24.0

var _text: Label


func _ready() -> void:
	_text = get_node_or_null("Text") as Label
	if _text:
		return
	if theme_type_variation.is_empty():
		theme_type_variation = &"SpeechBubble"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text = Label.new()
	_text.theme_type_variation = &"SpeechBubbleText"
	add_child(_text)
	hide()


func say(text: String) -> void:
	_text.text = text
	var font := _text.get_theme_font("font")
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, _text.get_theme_font_size("font_size")).x
	var wraps := width > max_text_width
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wraps else TextServer.AUTOWRAP_OFF
	_text.custom_minimum_size.x = max_text_width if wraps else 0.0
	show()
	scale = Vector2.ONE * POP_SCALE
	create_tween().tween_property(self, "scale", Vector2.ONE, POP_DURATION) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## A wrapped label only knows its height once it has its width, so the bubble refits each frame.
func _process(_delta: float) -> void:
	reset_size()
	pivot_offset = Vector2(TAIL_X, size.y) if tail == Tail.DOWN else Vector2(0, size.y - TAIL_Y)


## Drawn after the panel, so the tail's fill covers the panel's border where they join.
func _draw() -> void:
	var style := get_theme_stylebox("panel") as StyleBoxFlat
	if tail == Tail.DOWN:
		var border := float(style.border_width_bottom)
		var y0 := size.y - border - 2.0
		var left := Vector2(TAIL_X, y0)
		var right := Vector2(TAIL_X + TAIL_WIDTH, y0)
		var tip := Vector2(TAIL_X + 4.0, size.y + tail_length)
		draw_colored_polygon(PackedVector2Array([left, right, tip]), style.bg_color)
		draw_polyline(PackedVector2Array([Vector2(left.x, size.y - border), tip, Vector2(right.x, size.y - border)]),
			style.border_color, TAIL_LINE, true)
	else:
		var border := float(style.border_width_left)
		var low := size.y - TAIL_Y
		var high := low - TAIL_HEIGHT
		var tip := Vector2(-tail_length, low + 6.0)
		draw_colored_polygon(PackedVector2Array([Vector2(border + 2.0, high), Vector2(border + 2.0, low), tip]), style.bg_color)
		draw_polyline(PackedVector2Array([Vector2(border, high), tip, Vector2(border, low)]),
			style.border_color, TAIL_LINE, true)
