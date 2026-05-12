extends Sprite2D

const MOVE_SPEED = 1000
const GRAVITY = 2000
var min_y = -576.5
var max_y = 578.5

func _ready() -> void:
	set_process(false)

func activate() -> void:
	set_process(true)

func deactivate() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position.y -= MOVE_SPEED * _delta
	else:
		position.y += GRAVITY * _delta
	position.y = clamp(position.y, min_y, max_y)
