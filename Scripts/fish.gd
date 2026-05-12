extends Sprite2D

var move_distance = 300
var move_time = 0.2


var min_y =-774.804
var max_y = 785.015 
func _ready() -> void:
	position.y = randf_range(min_y, max_y)


func _on_timer_timeout() -> void:
	var direction = randi_range(-1, 1)
	
	if direction == 0:
		return
	
	var target_y = clamp(position.y + direction * move_distance, min_y, max_y)
	var target_position = Vector2(position.x, target_y)
	
	var t = create_tween()
	t.tween_property(self, "position", target_position, move_time)
