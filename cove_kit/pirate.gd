class_name Pirate
extends Control

## Captain Emmy, the guide in the bottom-left corner: a pose for each moment, and a speech bubble
## above her. Taps pass straight through her. Each game says what she says, in a script extending
## this one, set on its instance of pirate.tscn.

enum Pose { WAITING, CHEERING, POINTING }

const POSES := {
	Pose.WAITING: preload("res://cove_kit/emmy/waiting.svg"),
	Pose.CHEERING: preload("res://cove_kit/emmy/cheering.svg"),
	Pose.POINTING: preload("res://cove_kit/emmy/pointing.svg"),
}
## The bubble's left edge, and the room under it for its tail.
const BUBBLE_X := 30.0
const BUBBLE_GAP := 30.0
const ASIDE_ALPHA := 0.25
## In viewport pixels: wide enough to keep a marker, its ring and a name tag clear.
const KEEP_CLEAR_MARGIN := 60.0
const FADE := 0.2
## The share of her height drawn below the screen edge, so hopping doesn't lift her body clear of it.
const BELOW_EDGE := 50.0 / 430.0
## She squashes and springs back when she changes pose, and hops for joy. The bubble stays still,
## so it's easy to read.
const SQUASH := 0.08
const SQUASH_DURATION := 0.5
const HOP := 18.0
const HOP_UP := 0.13
const HOP_DOWN := 0.17
const HOPS := 2

@onready var _figure: TextureRect = $Figure
@onready var _bubble: SpeechBubble = $Bubble

var _fade: Tween
var _aside := false
var _leaving := false
var _squash := 0.0
var _hop := 0.0
var _squash_tween: Tween
var _hop_tween: Tween
## A point on screen to keep clear, or null.
var _keep_clear: Variant = null


func _process(_delta: float) -> void:
	var stretch := -_squash
	var below := _figure.size.y * BELOW_EDGE
	var standing := size.y - _figure.size.y + below
	_figure.pivot_offset = Vector2(_figure.size.x / 2.0, _figure.size.y - below)
	_figure.scale = Vector2(1.0 - stretch / 2.0, 1.0 + stretch)
	_figure.position.y = standing - _hop
	_bubble.position = Vector2(BUBBLE_X, standing - BUBBLE_GAP - _bubble.size.y)
	_step_aside(_keep_clear != null and _covers(_keep_clear, KEEP_CLEAR_MARGIN))


## Says `line` in `new_pose`, coming back if she had left. With `keep_clear`, a point on screen,
## she fades while she would hide it.
func speak(new_pose: Pose, line: String, keep_clear: Variant = null) -> void:
	_come_back()
	_show_pose(new_pose)
	_bubble.say(line)
	_keep_clear = keep_clear


func wait() -> void:
	_show_pose(Pose.WAITING)
	_bubble.hide()
	_keep_clear = null


## Stands beside something on screen, gesturing to it without a word. She fades if she would hide
## `keep_clear`.
func present(keep_clear: Vector2) -> void:
	_come_back()
	_show_pose(Pose.POINTING)
	_bubble.hide()
	_keep_clear = keep_clear


## Fades out and steps off. Speaking or presenting brings her back.
func leave() -> void:
	if not visible or _leaving:
		return
	_leaving = true
	_aside = false
	_keep_clear = null
	_fade_to(0.0).tween_callback(func() -> void:
		hide()
		modulate.a = 1.0
		_leaving = false)


## Stops talking but keeps her pose, so her bubble doesn't sit over a card opened beside her.
func hush() -> void:
	_bubble.hide()


func hop_for_joy() -> void:
	if _hop_tween:
		_hop_tween.kill()
	_hop_tween = create_tween()
	for i in HOPS:
		_hop_tween.tween_property(self, "_hop", HOP, HOP_UP).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_hop_tween.tween_property(self, "_hop", 0.0, HOP_DOWN).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func current_pose() -> Pose:
	return POSES.find_key(_figure.texture)


func is_speaking() -> bool:
	return _bubble.visible


func _show_pose(new_pose: Pose) -> void:
	if _figure.texture == POSES[new_pose]:
		return
	_figure.texture = POSES[new_pose]
	if _squash_tween:
		_squash_tween.kill()
	_squash_tween = create_tween()
	_squash_tween.tween_property(self, "_squash", 0.0, SQUASH_DURATION).from(SQUASH) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


## Whether she or her bubble is over a point on screen, or within `margin` of it.
func _covers(screen_point: Vector2, margin: float) -> bool:
	for part: Control in [_figure, _bubble]:
		if part.visible and part.get_global_rect().grow(margin).has_point(screen_point):
			return true
	return false


func _step_aside(aside: bool) -> void:
	if aside == _aside:
		return
	_aside = aside
	_fade_to(ASIDE_ALPHA if aside else 1.0)


## Fades back in if she has stepped off or is on her way.
func _come_back() -> void:
	if visible and not _leaving:
		return
	if not visible:
		modulate.a = 0.0
		show()
	_leaving = false
	_fade_to(1.0)


func _fade_to(alpha: float) -> Tween:
	if _fade:
		_fade.kill()
	_fade = create_tween()
	_fade.tween_property(self, "modulate:a", alpha, FADE)
	return _fade
