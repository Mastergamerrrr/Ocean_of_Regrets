extends Area2D

@export var interact_name: String = ""
@export var is_interactable: bool = true
@export var target_scene: String = ""
@export var spawn_point_name: String = ""

var interact: Callable = func():
	Global.spawn_point = spawn_point_name
	Transition.transition_to(target_scene)
