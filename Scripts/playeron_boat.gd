extends CharacterBody2D
const SPEED = 70.0
const JUMP_VELOCITY = -200.0
@onready var animated_spriteboat: AnimatedSprite2D = $BOAT/PLAYERBOATAnim
@onready var spriteb: Sprite2D = $BOAT
@onready var row_sound: AudioStreamPlayer2D = $RowSound

var footstep_timer: float = 0.0
const ROW_INTERVAL: float = 8.91

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction > 0:
		animated_spriteboat.flip_h = false
		spriteb.flip_h = false
	elif direction < 0:
		animated_spriteboat.flip_h = true
		spriteb.flip_h = true

	if direction:
		velocity.x = direction * SPEED
		animated_spriteboat.play("Row")
		if is_on_floor():
			footstep_timer -= delta
			if footstep_timer <= 0.0:
				row_sound.play()
				footstep_timer = ROW_INTERVAL
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_spriteboat.play("Idle")
		footstep_timer = 0.0
		row_sound.stop()

	move_and_slide()
