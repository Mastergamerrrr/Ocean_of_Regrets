extends Node

func _ready() -> void:
	var player = $PlayeronBoat
	var spawn = get_node_or_null(Global.spawn_point)
	if spawn:
		player.global_position = spawn.global_position
		
