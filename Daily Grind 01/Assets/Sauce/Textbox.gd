extends Control

signal next_text
signal display_finished

export var display_sped := 20.0
export var bbcode_text := "" setget set_bbcode_text

onready var _rich_text_label: RichTextLabel = $RichTextLabel
onready var _name_label: Label = $Namebox/Label
onready var _blinking_arrow: Control = $RichTextLabel/Textarrow
onready var _anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	hide()
	_blinking_arrow.hide()
	_name_label.text = ""
	_rich_text_label.bbcode_text = ""
	_rich_text_label.visible_characters = 0
	_tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")
	show()
	display("Hello lesbians", "Narrator",10)
	yield(self,"next_text")
	display("What should we say next?", "Narrator",25)
	yield(fade_in_async(),"completed")
	display("Hello!")
	
func display(text: String, character_name := "", speed := display_sped) -> void:
	set_bbcode_text(text)
	if speed != display_sped:
		display_sped = speed
	if character_name != "":
		_name_label.text = character_name
		_name_label.show()
	else:
		_name_label.hide()
			
func set_bbcode_text(text:String) -> void :
	bbcode_text = text
	if not is_inside_tree():
		yield(self,"ready")
		
	_blinking_arrow.hide()
	_rich_text_label.bbcode_text= bbcode_text
	call_deferred("_begin_dialogue_display")

func _begin_dialogue_display():
	var character_count = _rich_text_label.get_total_character_count()
	_tween.interpolate_property(_rich_text_label, "visible_characters", 0, character_count, character_count / display_sped)
	_tween.start()

onready var _tween: Tween = $Tween

func _on_Tween_tween_all_completed():
	emit_signal("display_finished")
	_blinking_arrow.show()
	
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		if _blinking_arrow.visible:
			emit_signal("next_text")
		else:
			_tween.seek(INF)

func fade_in_async():
	_anim_player.play("Fade_in")
	_anim_player.seek(0.0, true)
	yield(_anim_player,"animation_finished")
	
func fade_out_async():
	_anim_player.play("Fade_out")
	yield(_anim_player,"animation_finished")
