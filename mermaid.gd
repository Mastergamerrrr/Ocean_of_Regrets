extends Node2D

func _ready() -> void:
	$Interactable.interact = func():
		get_tree().change_scene_to_file("res://Scenes/mermaid_talk.tscn")
