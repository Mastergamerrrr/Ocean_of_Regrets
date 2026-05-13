extends Node2D

@export var next_scene_path: String = "res://Scenes/tutorial_2.tscn"

@onready var skip_button: Button = $UI/SkipButton

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)

func _on_skip_pressed() -> void:
	Transition.transition_to(next_scene_path)
