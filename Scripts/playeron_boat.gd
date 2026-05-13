extends CharacterBody2D
const SPEED = 70.0
const JUMP_VELOCITY = -200.0

enum FishingState {IDLE, CASTING, MINIGAME, CAUGHT, REELING, WAITING}
var fishing_state: FishingState = FishingState.IDLE
var is_fishing := false
var current_fish_data: Dictionary = {}
var is_ending:bool = false
var current_water_type: String = ""

@onready var animated_spriteboat: AnimatedSprite2D = $BOAT/PLAYERBOATAnim
@onready var spriteb: Sprite2D = $BOAT
@onready var row_sound: AudioStreamPlayer2D = $RowSound
@onready var throw_sound: AudioStreamPlayer2D = $ThrowSound
@onready var cancel_sound: AudioStreamPlayer2D = $CancelSound

var footstep_timer: float = 0.0
const ROW_INTERVAL: float = 8.91

signal fish_caught

func _ready() -> void:
	animated_spriteboat.animation_finished.connect(_on_animation_finished)
	current_water_type = get_tree().current_scene.name.to_lower()

func _physics_process(delta: float) -> void:
	if is_fishing:
		if Input.is_action_just_pressed("cancel_cast"):
			if fishing_state == FishingState.CASTING or fishing_state == FishingState.WAITING:
				_end_fishing()
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	# REMOVED jump feature (boats don't fly! 🚣)

	if Input.is_action_just_pressed("Fishing") and is_on_floor():
		_start_casting()
		return

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

func _start_casting() -> void:
	if fishing_state != FishingState.IDLE: 
		return
	fishing_state = FishingState.CASTING
	is_fishing = true
	velocity = Vector2.ZERO
	animated_spriteboat.play("Fishboat")
	$CancelCastComponent.show()
	throw_sound.play()
	
func _start_waiting() -> void:
	fishing_state = FishingState.WAITING
	var wait_time = GameManager.get_wait_time()
	$BiteTimer.wait_time = wait_time
	$BiteTimer.start()
	print("Waiting %.1f seconds for a bite..." % wait_time)

func _start_minigame() -> void:
	if fishing_state != FishingState.WAITING:
		return
	fishing_state = FishingState.MINIGAME
	$BiteTimer.stop()
	
	var fishing_spot = $CastComponent.current_fishing_spot
	var fish_node_name = current_water_type.capitalize() + "Fishes"
	var fish_node = fishing_spot.get_parent().get_node(fish_node_name)
	current_fish_data = fish_node.roll_fish()
	
	var minigame = load("res://Scenes/fishing_minigame.tscn").instantiate()
	get_tree().current_scene.add_child(minigame)
	minigame.player_ref = self
	minigame.fish_data = current_fish_data

func minigame_success() -> void:
	if fishing_state != FishingState.MINIGAME:
		return
	$BiteTimer.stop()
	fishing_state = FishingState.CAUGHT
	animated_spriteboat.play("Caughtfishboat")
	
	await animated_spriteboat.animation_finished
	
	var popup = load("res://Scenes/catch_popup.tscn").instantiate()
	get_tree().current_scene.add_child(popup)
	popup.show_result(current_fish_data, current_water_type)
	print("current_fish_data: ", current_fish_data)


func _end_fishing() -> void:
	fishing_state = FishingState.REELING
	is_fishing = true 
	$BiteTimer.stop() 
	animated_spriteboat.play_backwards("Fishboat")
	$CastComponent.show()
	$CancelCastComponent.hide()
	cancel_sound.play()

func minigame_fail() -> void:
	if fishing_state != FishingState.MINIGAME:
		return
	$BiteTimer.stop()
	$CastComponent.reset() 
	_end_fishing()
	
	var anim_length = animated_spriteboat.sprite_frames.get_frame_count("Fishboat") / 6.0
	await get_tree().create_timer(anim_length).timeout
	if fishing_state == FishingState.REELING:
		fishing_state = FishingState.IDLE
		is_fishing = false  
		animated_spriteboat.play("Idle")

func _on_animation_finished() -> void:
	match fishing_state:
		FishingState.CASTING:
			_start_waiting()
		FishingState.CAUGHT:
			emit_signal("fish_caught")
			fishing_state = FishingState.IDLE
			is_fishing = false
			animated_spriteboat.play("Idle")
			$CastComponent.reset() 
			$CancelCastComponent.hide()
		FishingState.REELING:
			fishing_state = FishingState.IDLE
			is_fishing = false
			animated_spriteboat.play("Idle")
			$CastComponent.reset() 
			$CancelCastComponent.hide()

func _on_bite_timer_timeout() -> void:
	_start_minigame()
	
