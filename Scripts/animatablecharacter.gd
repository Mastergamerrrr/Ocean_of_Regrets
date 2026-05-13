extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fish: AnimationPlayer = $FISH


func flip():
	animation_player.play("flip")

func fishboat():
	fish.play("fishing")
