extends CharacterBody2D
const SPEED = 70.0
const JUMP_VELOCITY = -200.0
@onready var animated_sprite: AnimatedSprite2D = $PlayerAnimate
@onready var animated_spritefish: AnimatedSprite2D = $PlayerAnimateFish
@onready var footstep_grass: AudioStreamPlayer2D = $FootstepGrass
@onready var footstep_stone: AudioStreamPlayer2D = $FootstepStone
@onready var footstep_wood: AudioStreamPlayer2D = $FootstepWood
var current_surface: String = "grass"
var footstep_timer: float = 0.0
const FOOTSTEP_INTERVAL: float = 0.4
var is_locked: bool = false

func lock_movement():
	is_locked = true
	velocity = Vector2.ZERO
	animated_sprite.play("Idle")
	footstep_grass.stop()
	footstep_stone.stop()
	footstep_wood.stop()

func unlock_movement():
	is_locked = false

func _physics_process(delta: float) -> void:
	if is_locked:
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.play("Walk")
		if is_on_floor():
			footstep_timer -= delta
			if footstep_timer <= 0.0:
				_play_footstep()
				footstep_timer = FOOTSTEP_INTERVAL
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("Idle")
		footstep_timer = 0.0
		footstep_grass.stop()
		footstep_stone.stop()
		footstep_wood.stop()
	move_and_slide()

func _play_footstep():
	print("Trying to play: ", current_surface, " | is playing: ", footstep_grass.playing)
	if current_surface == "grass":
		footstep_grass.play()
	elif current_surface == "stone":
		footstep_stone.play()
	elif current_surface == "wood":
		footstep_wood.play()

func set_surface(surface: String):
	if current_surface != surface:
		footstep_grass.stop()
		footstep_stone.stop()
		footstep_wood.stop()
		footstep_timer = 0.0
		current_surface = surface
	print("Surface changed to: ", current_surface)
