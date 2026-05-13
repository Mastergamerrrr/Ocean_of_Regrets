extends Node2D

func _ready() -> void:
	var all_max = GameManager.owned_upgrades["rod"] >= 3 \
		and GameManager.owned_upgrades["hook"] >= 3 \
		and GameManager.owned_upgrades["area"] >= 3
	
	visible = all_max
	$Interactable.monitoring = all_max
	$Interactable.monitorable = all_max
	$Interactable.is_interactable = all_max
	
	$Interactable.interact = func():
		get_tree().change_scene_to_file("res://Scenes/mermaid_talk.tscn")
