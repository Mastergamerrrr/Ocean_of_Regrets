extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func flip():
	animation_player.play("flip")
