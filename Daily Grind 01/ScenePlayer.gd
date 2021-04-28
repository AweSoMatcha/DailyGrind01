class_name ScenePlayer
extends Node

signal scene_finished

const KEY_END_OF_SCENE := -1

var _scene_data := {
	0: {
		character = "naomi",
		side = "left",
		animation = "enter",
		line = "Hi there! My name's Sophia.",
		next = 1
		},
	1: {
		character = "lillie",
		side = "right",
		animation = "enter",
		next = 2
	},
	2: {
		character = "naomi",
		line = "Yo.",
		next = -1
	}
}

onready var _text_box := $Textbox
onready var _character_displayer := $Charadisp
onready var _background := $Background

func _ready():
	yield(_text_box.fade_in_async(), "completed")
	run_scene()

func run_scene():
	var key = _scene_data.keys()[0]
	
	while key != KEY_END_OF_SCENE:
		
		var curr_scene:Dictionary = _scene_data[key]
		
		if "background" in curr_scene:
			var bg: Background = ResourceDB.get_background(curr_scene.background)
		
		var character: Character = (
			ResourceDB.get_character(curr_scene.character)
			if "character" in curr_scene
			else ResourceDB.get_narrator()
		)

		if "character" in curr_scene:
			
			var side: String = curr_scene.side if "side" in curr_scene else _character_displayer.SIDE.LEFT
			
			var animation: String = curr_scene.get("animation", "")
			var expression: String = curr_scene.get("expression","")
			
			_character_displayer.display(character, side, expression, animation)
			
			if not "line" in curr_scene:
				yield(_character_displayer, "display_finished")
				
		if "line" in curr_scene:
			_text_box.display(curr_scene.line, character.display_name)
			
			yield(_text_box, "next_text")
			key = curr_scene.next
			
		else:
			key = curr_scene.next
	_character_displayer.hide()
	emit_signal("scene_finished")
	
