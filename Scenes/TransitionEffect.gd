extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var transition_sound = $TransitionSound
@onready var travel_label = $TravelLabel
var tween: Tween
var dot_timer: float = 0.0
var dot_count: int = 0
var is_loading: bool = false

func _ready():
	_set_progress(1.0)
	travel_label.visible = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if is_loading:
		dot_timer += delta
		if dot_timer >= 0.5:
			dot_timer = 0.0
			dot_count = (dot_count + 1) % 4
			travel_label.text = "Travelling" + ".".repeat(dot_count)

func show_loading():
	is_loading = true
	travel_label.visible = true
	travel_label.text = "Travelling"
	_set_progress(0.0)

func hide_loading():
	is_loading = false
	travel_label.visible = false
	_set_progress(1.0)

func transition_to(target_scene: String):
	if tween:
		tween.kill()
	transition_sound.play()
	tween = create_tween()
	tween.tween_method(_set_progress, 1.0, 0.0, 1.2)
	await tween.finished
	get_tree().change_scene_to_file(target_scene)
	transition_sound.play()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, 0.5)

func _set_progress(value: float):
	color_rect.material.set_shader_parameter("progress", value)

func travel_to(target_scene: String):
	get_tree().change_scene_to_file(target_scene)
	# Fade back in
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, 0.5)
