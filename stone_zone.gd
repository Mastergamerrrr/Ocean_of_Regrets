extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_surface"):
		body.set_surface("stone")

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_surface"):
		body.set_surface("grass")
