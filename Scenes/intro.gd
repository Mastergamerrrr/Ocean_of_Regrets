extends Node2D

@export var next_scene_path: String = "res://Scenes/tutorial_1.tscn"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name: String) -> void:
	get_tree().change_scene_to_file(next_scene_path)
