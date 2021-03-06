extends Node2D

signal display_finished

const SIDE = {LEFT = "left", MID="mid", RIGHT = "right"}
const COLOR_WHITE_TRANSPARENT = Color(1.0,1.0,1.0,0.0)
const ANIMATIONS = {"enter": "_enter", "leave": "_leave"}
var _displayed = {left = null, right = null}

onready var _tween : Tween = $Tween
onready var _left_sprite: Sprite = $Left
onready var _mid_sprite: Sprite = $Mid
onready var _right_sprite: Sprite = $Right


func _ready():
	_left_sprite.hide()
	_mid_sprite.hide()
	_right_sprite.hide()
	_tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")

	# # # # # TEST # # # # # #
#	var character_test = [preload("res://Assets/Characters/Test/Lillie_test.tres"),preload("res://Assets/Characters/Test/Naomi_cardboard.tres")]
	# # # # # TEST # # # # # #

	pass # Replace with function body.


func _on_Tween_tween_all_completed() :
	emit_signal("display_finished")
	

func display(character: Character, side: String = SIDE.LEFT, expression="",animation=""):
	assert(side in SIDE.values())
	var sprite: Sprite = _left_sprite if side == SIDE.LEFT else _right_sprite if side == SIDE.RIGHT else _mid_sprite
	if character== _displayed.left:
		sprite = _left_sprite
	elif character == _displayed.right:
		sprite = _right_sprite
	elif character == _displayed.mid:
		sprite = _mid_sprite
		
	else:
		_displayed[side] = character
		
	sprite.texture = character.get_image(expression)
	
	sprite.show()

	if animation != "":
		call(ANIMATIONS[animation],side,sprite)
		
func _enter(from_side:String, sprite:Sprite):
	var offset := -200 if from_side == SIDE.LEFT else 200
	var start := sprite.position + Vector2(offset,0.0)
	var end := sprite.position
	
	_tween.interpolate_property(
		sprite, "position", start, end, 0.5, Tween.TRANS_QUINT, Tween.EASE_OUT
	)	
	_tween.interpolate_property(sprite, "modulate", COLOR_WHITE_TRANSPARENT, Color.white, 0.25)
	_tween.start()
	
	sprite.position = start
	sprite.modulate = COLOR_WHITE_TRANSPARENT

func _leave(from_side:String, sprite:Sprite):
	var offset := -400 if from_side == SIDE.LEFT else 400
	var start := sprite.position
	var end := sprite.position + Vector2(offset,0.0)
	
	_tween.interpolate_property(
		sprite, "position", start, end, 0.3, Tween.TRANS_QUINT, Tween.EASE_OUT
	)
	_tween.interpolate_property(sprite, "modulate", Color.white, COLOR_WHITE_TRANSPARENT, 0.25, Tween.TRANS_LINEAR,Tween.EASE_OUT, 0.25	)
	_tween.start()
	_tween.seek(0.0)
	
func _unhandled_input(event:InputEvent):
	if event.is_action_pressed("ui_accept") and _tween.is_active():
		_tween.seek(INF)
		
