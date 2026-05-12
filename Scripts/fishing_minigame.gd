extends CanvasLayer

var player_ref: CharacterBody2D = null
var is_on_bar = false
var grace_timer: float = 1.0
var fish_data: Dictionary = {} 
var is_ending: bool = false

var shake_strength: float = 0.0
var shake_timer: float = 0.0
const SHAKE_DECAY: float = 6.0
var original_offset: Vector2 = Vector2.ZERO
var hold_time: float = 0.0

@onready var minigame_battle_sound: AudioStreamPlayer2D = $FishingMinigame/MinigameBattleSound
@onready var catch_sound: AudioStreamPlayer2D = $FishingMinigame/CatchSound

@export var catch_sound_delay: float = 0.0
@export var catch_sound_duration: float = 3.0

func _ready() -> void:
	$FishingMinigame/TextureProgressBar.value = 20
	$FishingMinigame/outside/RigidBody2D.activate()
	original_offset = offset
	minigame_battle_sound.play()

func _process(delta: float) -> void:
	if grace_timer > 0:
		grace_timer -= delta
	
	if shake_timer > 0:
		shake_timer -= delta
		var t = Time.get_ticks_msec() * 0.01
		var shake_x = sin(t) * shake_strength
		var shake_y = cos(t * 0.7) * shake_strength
		offset = original_offset + Vector2(shake_x, shake_y)
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY * delta)
	else:
		offset = original_offset

func trigger_shake(strength: float = 6.0, duration: float = 0.25) -> void:
	shake_strength = strength
	shake_timer = duration

func _on_area_2d_body_entered(_body: Node2D) -> void:
	is_on_bar = true

func _on_area_2d_body_exited(_body: Node2D) -> void:
	is_on_bar = false

func _on_timer_timeout() -> void:
	if is_ending:
		return
	var fish_area = $FishingMinigame/fish/Area2D
	var bar_area = $FishingMinigame/outside/RigidBody2D/inside/Area2D

	var fill_speed = 0.0
	if player_ref != null:
		fill_speed = player_ref.get_node("FishingRodUpgrades").get_fill_speed()

	print("Bar value: ", $FishingMinigame/TextureProgressBar.value)

	if bar_area.overlaps_area(fish_area):
		%TextureProgressBar.value += fill_speed
		hold_time += 0.1
		var intensity = clamp(hold_time * 1.2, 1.0, 4.0)
		var duration = clamp(hold_time * 0.1, 0.12, 0.3)
		trigger_shake(intensity, duration)
	else:
		hold_time = 0.0
		if grace_timer <= 0:
			%TextureProgressBar.value -= fill_speed
			trigger_shake(2.0, 0.15)

	if %TextureProgressBar.value >= 100:
		is_ending = true
		minigame_battle_sound.stop()
		print("Caught Fish!")
		await get_tree().create_timer(0.5).timeout
		if player_ref != null:
			player_ref.minigame_success()
		queue_free()
	elif %TextureProgressBar.value <= 0:
		is_ending = true
		minigame_battle_sound.stop()
		print("Fish Got Away!")
		if player_ref != null:
			player_ref.minigame_fail()
		queue_free()

func _end_minigame(success: bool) -> void:
	$FishingMinigame/outside/RigidBody2D/inside.deactivate()
	if success:
		if player_ref != null:
			player_ref.minigame_success()
	else:
		if player_ref != null:
			player_ref.minigame_fail()
	queue_free()

func _play_catch_sound() -> void:
	await get_tree().create_timer(catch_sound_delay).timeout
	catch_sound.play()
	await get_tree().create_timer(catch_sound_duration).timeout
	catch_sound.stop()
