extends CanvasLayer

@onready var color_rect = $ColorRect
var tween: Tween

func _ready():
	_set_progress(1.0)

func transition_to(target_scene: String):
	# Kill any existing tween first
	if tween:
		tween.kill()
	
	# Iris close
	tween = create_tween()
	tween.tween_method(_set_progress, 1.0, 0.0, 0.5)
	await tween.finished
	
	get_tree().change_scene_to_file(target_scene)
	
	# Iris open
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, 0.5)

func _set_progress(value: float):
	color_rect.material.set_shader_parameter("progress", value)
