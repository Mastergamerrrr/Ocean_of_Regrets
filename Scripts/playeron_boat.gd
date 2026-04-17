extends CharacterBody2D

const SPEED = 70.0
const JUMP_VELOCITY = -200.0
const FISH_ACTION = "fish"
const CAST_COOLDOWN = 1.0
const BITE_TIME_MIN = 2.0
const BITE_TIME_MAX = 4.5
const REACTION_WINDOW = 1.25
const REEL_DURATION = 3.0
const SAFE_ZONE_LOW = 40.0
const SAFE_ZONE_HIGH = 60.0
const BALANCE_DECAY = 20.0
const BALANCE_INPUT_POWER = 40.0
const FISH_STRENGTH_MIN = 1.0
const FISH_STRENGTH_MAX = 1.6
const FISH_COLLISION_MASK = 2
const TEST_FISH_COUNT = 1
const TEST_FISH_MIN_DISTANCE = 48.0
const TEST_FISH_MAX_DISTANCE = 140.0

enum FishingState {
	IDLE,
	WAITING_BITE,
	BITE_READY,
	REELING,
	COOLDOWN
}

var fishing_state: FishingState = FishingState.IDLE
var cast_cooldown := 0.0
var bite_timer := 0.0
var reaction_timer := 0.0
var reel_timer := 0.0
var balance_value := 50.0
var stable_time := 0.0
var fish_strength := 0.0
var caught_fish := 0
var target_fish: Area2D = null

var fish_scene: PackedScene = preload("res://Scenes/fishing_fish.tscn")

@onready var animated_spriteboat: AnimatedSprite2D = $BOAT/PLAYERBOATAnim
@onready var spriteb: Sprite2D = $BOAT
@onready var hook_area: Area2D = $FishingHook
@onready var info_label: Label = $FishingUI/InfoLabel
@onready var balance_label: Label = $FishingUI/BalanceLabel
@onready var balance_bar: ProgressBar = $FishingUI/BalanceBar
@onready var catch_panel: Panel = $FishingUI/CatchPanel
@onready var catch_meter: ProgressBar = $FishingUI/CatchPanel/CatchMeter
@onready var fish_marker: Label = $FishingUI/CatchPanel/FishMarker

func _ready() -> void:
	randomize()
	_setup_fishing_input()
	hook_area.collision_layer = 0
	hook_area.collision_mask = FISH_COLLISION_MASK
	hook_area.monitoring = false
	if not hook_area.area_entered.is_connected(_on_FishingHook_area_entered):
		hook_area.area_entered.connect(_on_FishingHook_area_entered)
	if not hook_area.area_exited.is_connected(_on_FishingHook_area_exited):
		hook_area.area_exited.connect(_on_FishingHook_area_exited)
	_ensure_fish_present_for_testing()
	info_label.text = "Press F to cast your line"
	balance_label.text = "Catch Challenge"
	balance_bar.value = 50
	balance_label.visible = false
	balance_bar.visible = false
	catch_panel.visible = false
	_update_catch_ui()

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_process_fishing(delta)
	move_and_slide()

func _handle_movement(delta: float) -> void:
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

	if _is_fishing_active():
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.5 * delta)
		animated_spriteboat.play("Fishboat")
	elif direction != 0:
		velocity.x = direction * SPEED
		animated_spriteboat.play("Row")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		animated_spriteboat.play("Idle")

func _process_fishing(delta: float) -> void:
	if cast_cooldown > 0.0:
		cast_cooldown = max(cast_cooldown - delta, 0.0)

	if Input.is_action_just_pressed(FISH_ACTION):
		_handle_fish_input()

	match fishing_state:
		FishingState.WAITING_BITE:
			bite_timer -= delta
			if bite_timer <= 0.0:
				target_fish = _find_overlapping_fish()
				if target_fish != null:
					_start_bite()
				else:
					_fail_fish("No fish nearby. Move and cast again.")
			elif bite_timer <= 1.0:
				info_label.text = "Fish are circling..."
		FishingState.BITE_READY:
			reaction_timer -= delta
			if reaction_timer <= 0.0:
				_fail_fish("The fish escaped!")
			else:
				info_label.text = "Hook set! Press F now!"
		FishingState.REELING:
			reel_timer -= delta
			_update_balance(delta)
			if stable_time >= 1.5:
				_finish_fish(true)
			elif reel_timer <= 0.0:
				_finish_fish(false)
		FishingState.COOLDOWN:
			if cast_cooldown <= 0.0:
				fishing_state = FishingState.IDLE
				info_label.text = "Press F to cast your line"

func _handle_fish_input() -> void:
	if fishing_state == FishingState.IDLE and cast_cooldown <= 0.0:
		_cast_line()
	elif fishing_state == FishingState.BITE_READY:
		_hook_fish()

func _cast_line() -> void:
	fishing_state = FishingState.WAITING_BITE
	bite_timer = randf_range(BITE_TIME_MIN, BITE_TIME_MAX)
	hook_area.monitoring = true
	target_fish = _find_overlapping_fish()
	info_label.text = "Casting... wait for the tug"
	animated_spriteboat.play("Fishboat")

func _start_bite() -> void:
	if target_fish == null:
		target_fish = _find_overlapping_fish()
	if target_fish == null:
		_fail_fish("The bait drifted past the fish.")
		return

	fishing_state = FishingState.BITE_READY
	reaction_timer = REACTION_WINDOW
	fish_strength = randf_range(FISH_STRENGTH_MIN, FISH_STRENGTH_MAX)
	info_label.text = "Something bit! Press F!"

func _hook_fish() -> void:
	if target_fish == null:
		_fail_fish("No fish on the hook.")
		return

	fishing_state = FishingState.REELING
	reel_timer = REEL_DURATION
	balance_value = 50.0
	stable_time = 0.0
	info_label.text = "Reel in! Use left/right and keep fish in the green zone"
	balance_label.text = "Catch Challenge"
	balance_bar.value = balance_value
	balance_label.visible = true
	balance_bar.visible = true
	catch_panel.visible = true
	_update_catch_ui()

func _update_balance(delta: float) -> void:
	var drift := (balance_value - 50.0) * (BALANCE_DECAY * 0.0025) * fish_strength * delta
	var wobble := randf_range(-fish_strength, fish_strength) * delta * 10.0
	var player_input := Input.get_axis("ui_left", "ui_right") * BALANCE_INPUT_POWER * delta

	balance_value = clamp(balance_value + drift + wobble + player_input, 0.0, 100.0)
	balance_bar.value = balance_value
	_update_catch_ui()

	if balance_value >= SAFE_ZONE_LOW and balance_value <= SAFE_ZONE_HIGH:
		stable_time += delta
		info_label.text = "Keep steady!"
	else:
		stable_time = max(stable_time - delta * 1.5, 0.0)
		info_label.text = "Adjust left/right to stay in the green zone"

func _finish_fish(success: bool) -> void:
	hook_area.monitoring = false
	if success:
		caught_fish += 1
		info_label.text = "Caught fish! Total: %d" % caught_fish
		if is_instance_valid(target_fish):
			target_fish.queue_free()
			_spawn_test_fish()
		animated_spriteboat.play("Fishboat")
	else:
		info_label.text = "The fish got away..."
		animated_spriteboat.play("Idle")

	target_fish = null
	fishing_state = FishingState.COOLDOWN
	cast_cooldown = CAST_COOLDOWN
	_hide_catch_ui()

func _fail_fish(message: String) -> void:
	info_label.text = message
	fishing_state = FishingState.COOLDOWN
	cast_cooldown = CAST_COOLDOWN
	hook_area.monitoring = false
	target_fish = null
	_hide_catch_ui()

func _on_FishingHook_area_entered(_area: Area2D) -> void:
	if not _is_fish_area(_area):
		return

	target_fish = _area
	if fishing_state == FishingState.WAITING_BITE:
		bite_timer = min(bite_timer, 0.35)
		if bite_timer <= 0.0:
			_start_bite()

func _on_FishingHook_area_exited(_area: Area2D) -> void:
	if _area == target_fish:
		target_fish = _find_overlapping_fish()

func _setup_fishing_input() -> void:
	if not InputMap.has_action(FISH_ACTION):
		InputMap.add_action(FISH_ACTION)

	var has_fish_key := false
	for action_event in InputMap.action_get_events(FISH_ACTION):
		if action_event is InputEventKey and action_event.keycode == Key.KEY_F:
			has_fish_key = true
			break

	if has_fish_key:
		return

	var event := InputEventKey.new()
	event.keycode = Key.KEY_F
	InputMap.action_add_event(FISH_ACTION, event)

func _is_fish_area(area: Area2D) -> bool:
	return area != null and (area.is_in_group("fish") or (area.collision_layer & FISH_COLLISION_MASK) != 0)

func _find_overlapping_fish() -> Area2D:
	if not hook_area.monitoring:
		return null

	for fish_area in hook_area.get_overlapping_areas():
		if fish_area is Area2D and _is_fish_area(fish_area):
			return fish_area
	return null

func _ensure_fish_present_for_testing() -> void:
	var fish_count := get_tree().get_nodes_in_group("fish").size()
	if fish_count >= TEST_FISH_COUNT:
		return

	for _i in range(TEST_FISH_COUNT - fish_count):
		_spawn_test_fish()

func _spawn_test_fish() -> void:
	if fish_scene == null:
		return

	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var fish := fish_scene.instantiate() as Area2D
	if fish == null:
		return

	fish.top_level = true
	if not fish.is_in_group("fish"):
		fish.add_to_group("fish")

	scene_root.add_child(fish)
	var side := -1.0 if randf() < 0.5 else 1.0
	var offset := Vector2(side * randf_range(TEST_FISH_MIN_DISTANCE, TEST_FISH_MAX_DISTANCE), randf_range(12.0, 72.0))
	fish.global_position = global_position + offset

func _is_fishing_active() -> bool:
	return fishing_state == FishingState.WAITING_BITE or fishing_state == FishingState.BITE_READY or fishing_state == FishingState.REELING

func _update_catch_ui() -> void:
	catch_meter.value = balance_value
	var meter_height := catch_meter.size.y
	var ratio := 1.0 - (balance_value / 100.0)
	var fish_y := catch_meter.position.y + meter_height * ratio - 10.0
	fish_marker.position.y = clamp(fish_y, catch_meter.position.y - 6.0, catch_meter.position.y + meter_height - 12.0)

func _hide_catch_ui() -> void:
	balance_label.visible = false
	balance_bar.visible = false
	catch_panel.visible = false
	balance_bar.value = 50
