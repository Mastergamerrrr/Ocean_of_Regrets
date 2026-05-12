extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer



func attack():
	animation_player.play("attack")
