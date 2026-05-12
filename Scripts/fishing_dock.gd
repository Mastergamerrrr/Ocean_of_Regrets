extends Area2D

var player_inside = false

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("ui_accept"):
		print("Changing scene!")
		get_tree().change_scene_to_file("res://Lake.tscn")

func _on_body_entered(body):
	print("Something entered: ", body.name)
	if body.is_in_group("player"):
		print("Player entered!")
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
