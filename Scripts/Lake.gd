extends Node

func _ready() -> void:
	print("Global.spawn_point is: ", Global.spawn_point)
	var player = $PlayeronBoat
	var spawn = get_node_or_null(Global.spawn_point)
	print("Spawn node found: ", spawn)
	if spawn:
		player.global_position = spawn.global_position
