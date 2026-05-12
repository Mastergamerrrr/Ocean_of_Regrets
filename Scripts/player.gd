extends CharacterBody2D

const SPEED = 70.0
const JUMP_VELOCITY = -200.0

@onready var animated_sprite: AnimatedSprite2D = $PlayerAnimate
@onready var animated_spritefish: AnimatedSprite2D = $PlayerAnimateFish

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Flip sprite based on direction
	if direction > 0:
		animated_sprite.flip_h = false  # Facing right
	elif direction < 0:
		animated_sprite.flip_h = true  # Facing left
	
	# Handle movement and animations
	if direction:
		velocity.x = direction * SPEED
		# Play walking animation if moving
		animated_sprite.play("Walk")  # Make sure "walk" is the name of your walk animation
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		# Play idle animation when not moving
		animated_sprite.play("Idle")  # Make sure "idle" is the name of your idle animation

	move_and_slide()
