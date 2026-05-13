extends Node2D

@export var next_scene_path: String = "res://Scenes/tutorial_1.tscn"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skip_button: Button = $UI/SkipButton

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	skip_button.pressed.connect(_on_skip_pressed)

func _on_animation_finished(_anim_name: String) -> void:
	get_tree().change_scene_to_file(next_scene_path)

func _on_skip_pressed() -> void:
	animation_player.stop()
	get_tree().change_scene_to_file(next_scene_path)
