extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var transition_sound = $TransitionSound
var tween: Tween

func _ready():
	_set_progress(1.0)

func transition_to(target_scene: String):
	if tween:
		tween.kill()
	
	# Play sound and close iris
	transition_sound.play()
	tween = create_tween()
	tween.tween_method(_set_progress, 1.0, 0.0, 1.5)
	await tween.finished
	
	get_tree().change_scene_to_file(target_scene)
	
	# Play sound and open iris
	transition_sound.play()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, 0.5)

func _set_progress(value: float):
	color_rect.material.set_shader_parameter("progress", value)
