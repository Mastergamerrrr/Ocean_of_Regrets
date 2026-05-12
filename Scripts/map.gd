extends Control

# Node references
@onready var background_dim = $BackgroundDim
@onready var scroll_left = $ScrollLeft
@onready var scroll_right = $ScrollRight
@onready var map_container = $MapContainer

# --- TextureButtons for locations (adjust paths if needed) ---
@onready var store_button = $MapContainer/StoreButton
@onready var pond_button = $MapContainer/PondButton
@onready var lake_button = $MapContainer/LakeButton
@onready var ocean_button = $MapContainer/OceanButton

# --- Label references ---
@onready var store_label = $LocationLabels/StoreLabel
@onready var pond_label = $LocationLabels/PondLabel
@onready var lake_label = $LocationLabels/LakeLabel
@onready var ocean_label = $LocationLabels/OceanLabel

# Store original positions for reset
var scroll_left_start_pos: Vector2
var scroll_right_start_pos: Vector2
var map_container_start_scale: Vector2

# Animation settings
const ANIMATION_DURATION = 0.6
const BOUNCE_AMOUNT = 1.01
const BOUNCE_DURATION = 0.08

# Scene paths for teleportation (update with your actual file paths)
const STORE_SCENE = "res://Scenes/game.tscn"
const POND_SCENE = "res://Scenes/pond.tscn"
const LAKE_SCENE = "res://Scenes/lake.tscn"
const OCEAN_SCENE = "res://Scenes/ocean.tscn"

# Signals
signal map_closed()
signal location_selected(scene_path: String)   # Emitted when a location button is pressed

func _ready():
	set_process_input(true)
	
	await get_tree().process_frame
	
	scroll_left_start_pos = scroll_left.position
	scroll_right_start_pos = scroll_right.position
	map_container_start_scale = map_container.scale
	
	map_container.pivot_offset = map_container.size / 2.0
	scroll_left.pivot_offset = scroll_left.size / 2.0
	scroll_right.pivot_offset = scroll_right.size / 2.0
	
	_hide_labels()
	reset_to_hidden()
	#visible = false
	
	# Connect UI buttons
	$MapContainer/CloseButton.pressed.connect(_on_close_pressed)
	
	# Connect location buttons
	store_button.pressed.connect(_on_store_pressed)
	pond_button.pressed.connect(_on_pond_pressed)
	lake_button.pressed.connect(_on_lake_pressed)
	ocean_button.pressed.connect(_on_ocean_pressed)
	
	print("Map ready! Press Spacebar to open (test mode).")

func _hide_labels():
	store_label.visible = false
	pond_label.visible = false
	lake_label.visible = false
	ocean_label.visible = false

func _show_labels():
	store_label.visible = true
	pond_label.visible = true
	lake_label.visible = true
	ocean_label.visible = true

func reset_to_hidden():
	var center_x = scroll_left_start_pos.x + (scroll_right_start_pos.x - scroll_left_start_pos.x) / 2.0
	scroll_left.position.x = center_x
	scroll_right.position.x = center_x
	
	map_container.scale = Vector2(0.05, 0.05)
	map_container.modulate.a = 0.0
	background_dim.modulate.a = 0.0
	
	_hide_labels()

func open_map():
	visible = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(background_dim, "modulate:a", 0.7, ANIMATION_DURATION * 0.8)
	tween.tween_property(map_container, "modulate:a", 1.0, ANIMATION_DURATION * 0.5)
	tween.tween_property(map_container, "scale", Vector2(1.0, 1.0), ANIMATION_DURATION)
	
	tween.tween_property(scroll_left, "position:x", scroll_left_start_pos.x, ANIMATION_DURATION)
	tween.tween_property(scroll_right, "position:x", scroll_right_start_pos.x, ANIMATION_DURATION)
	
	tween.finished.connect(_add_bounce)

func _add_bounce():
	var bounce = create_tween()
	bounce.set_parallel(true)
	bounce.set_ease(Tween.EASE_IN_OUT)
	bounce.set_trans(Tween.TRANS_SINE)
	
	bounce.tween_property(map_container, "scale", Vector2(BOUNCE_AMOUNT, BOUNCE_AMOUNT), BOUNCE_DURATION)
	bounce.tween_property(scroll_left, "position:x", scroll_left_start_pos.x - 2, BOUNCE_DURATION)
	bounce.tween_property(scroll_right, "position:x", scroll_right_start_pos.x + 2, BOUNCE_DURATION)
	
	bounce.finished.connect(_return_to_normal)

func _return_to_normal():
	var settle = create_tween()
	settle.set_parallel(true)
	settle.set_ease(Tween.EASE_OUT)
	settle.set_trans(Tween.TRANS_SINE)
	
	settle.tween_property(map_container, "scale", Vector2(1.0, 1.0), BOUNCE_DURATION * 1.5)
	settle.tween_property(scroll_left, "position:x", scroll_left_start_pos.x, BOUNCE_DURATION * 1.5)
	settle.tween_property(scroll_right, "position:x", scroll_right_start_pos.x, BOUNCE_DURATION * 1.5)
	
	settle.finished.connect(_show_labels)

func close_map():
	_hide_labels()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(background_dim, "modulate:a", 0.0, ANIMATION_DURATION * 0.6)
	tween.tween_property(map_container, "modulate:a", 0.0, ANIMATION_DURATION * 0.4)
	
	var center_x = scroll_left_start_pos.x + (scroll_right_start_pos.x - scroll_left_start_pos.x) / 2.0
	
	tween.tween_property(scroll_left, "position:x", center_x, ANIMATION_DURATION)
	tween.tween_property(scroll_right, "position:x", center_x, ANIMATION_DURATION)
	tween.tween_property(map_container, "scale", Vector2(0.05, 0.05), ANIMATION_DURATION)
	
	tween.finished.connect(_on_close_finished)

func _on_close_finished():
	visible = false
	map_closed.emit()
	print("Map closed!")

func _on_close_pressed():
	close_map()

# --- Location button handlers ---
func _on_store_pressed():
	location_selected.emit(STORE_SCENE)

func _on_pond_pressed():
	location_selected.emit(POND_SCENE)

func _on_lake_pressed():
	location_selected.emit(LAKE_SCENE)

func _on_ocean_pressed():
	location_selected.emit(OCEAN_SCENE)

# --- Test input (spacebar) - commented out for production ---
#func _input(event):
#	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
#		if visible:
#			close_map()
#		else:
#			open_map()
