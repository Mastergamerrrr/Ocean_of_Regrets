extends Node2D

@export var main_menu_path: String = "res://Scenes/main_menu.tscn"

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # ESC key
		get_tree().change_scene_to_file(main_menu_path)
