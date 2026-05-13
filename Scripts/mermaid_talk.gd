extends Node2D # Or Control, depending on the parent node type

func _on_button_pressed():
	# Replace with the actual path to your "Back to Shore" scene
	get_tree().change_scene_to_file("res://Scenes/ending_1.tscn")

func _on_button_3_pressed():
	# Replace with the actual path to your "Keep Fishing" scene
	get_tree().change_scene_to_file("res://Scenes/ending_2.tscn")
