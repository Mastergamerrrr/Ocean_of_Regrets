extends Node2D
@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	if sprite_2d.frame == 0:
		interactable.is_interactable = false
		# do whatever you want here instead of changing frame
		print("car interacted!")
