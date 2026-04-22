extends Node2D
@onready var interact_label: Label = $InteractLabel
var current_interactions := []
var can_interact := true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			interact_label.hide()
			current_interactions[0].interact.call()
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		_update_outline()
		if current_interactions[0].is_interactable:
			interact_label.text = current_interactions[0].interact_name
			interact_label.show()
	else:
		interact_label.hide()
		_update_outline()

func _sort_by_nearest(area1, area2):
	var area1_distance = global_position.distance_to(area1.global_position)
	var area2_distance = global_position.distance_to(area2.global_position)
	return area1_distance < area2_distance

func _update_outline() -> void:
	for area in current_interactions:
		var sprite = area.get_parent().get_node_or_null("Sprite2D")
		if sprite and sprite.material:
			sprite.material.set_shader_parameter("show_outline", false)
	
	if current_interactions:
		current_interactions.sort_custom(_sort_by_nearest)
		var nearest = current_interactions[0]
		var sprite = nearest.get_parent().get_node_or_null("Sprite2D")
		if sprite and sprite.material:
			sprite.material.set_shader_parameter("show_outline", true)

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)
	_update_outline()

func _on_interact_range_area_exited(area: Area2D) -> void:
	var sprite = area.get_parent().get_node_or_null("Sprite2D")
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("show_outline", false)
	current_interactions.erase(area)
	_update_outline()
