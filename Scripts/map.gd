extends Control

# Node references
@onready var background_dim = $BackgroundDim
@onready var map_container = $MapContainer

# --- TextureButtons for locations ---
@onready var store_button = $MapContainer/StoreButton
@onready var pond_button = $MapContainer/PondButton
@onready var lake_button = $MapContainer/LakeButton
@onready var ocean_button = $MapContainer/OceanButton

# --- Label references ---
@onready var store_label = $LocationLabels/StoreLabel
@onready var pond_label = $LocationLabels/PondLabel
@onready var lake_label = $LocationLabels/LakeLabel
@onready var ocean_label = $LocationLabels/OceanLabel

# Animation settings
const ANIMATION_DURATION = 0.8
const BOUNCE_AMOUNT = 1.03
const BOUNCE_DURATION = 0.15

# Scene paths
const STORE_SCENE = "res://Scenes/game.tscn"
const POND_SCENE = "res://Scenes/pond_land.tscn"
const LAKE_SCENE = "res://Scenes/lake_land.tscn"
const OCEAN_SCENE = "res://Scenes/ocean_land.tscn"

var current_location: String = ""

# Signals
signal map_closed()
signal location_selected(scene_path: String)

func _ready():
	set_process_input(true)
	await get_tree().process_frame
	map_container.pivot_offset = map_container.size / 2.0
	_hide_labels()
	reset_to_hidden()

	$MapContainer/CloseButton.pressed.connect(_on_close_pressed)
	store_button.pressed.connect(_on_store_pressed)
	pond_button.pressed.connect(_on_pond_pressed)
	lake_button.pressed.connect(_on_lake_pressed)
	ocean_button.pressed.connect(_on_ocean_pressed)

func set_current_location(scene_path: String):
	current_location = scene_path
	_update_button_states()

func _update_button_states():
	# Dim and disable the button of current location
	store_button.modulate.a = 1.0
	pond_button.modulate.a = 1.0
	lake_button.modulate.a = 1.0
	ocean_button.modulate.a = 1.0
	
	store_button.disabled = false
	pond_button.disabled = false
	lake_button.disabled = false
	ocean_button.disabled = false

	match current_location:
		STORE_SCENE:
			store_button.modulate.a = 0.4
			store_button.disabled = true
		POND_SCENE:
			pond_button.modulate.a = 0.4
			pond_button.disabled = true
		LAKE_SCENE:
			lake_button.modulate.a = 0.4
			lake_button.disabled = true
		OCEAN_SCENE:
			ocean_button.modulate.a = 0.4
			ocean_button.disabled = true

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
	map_container.scale = Vector2(1.0, 1.0)
	map_container.modulate.a = 0.0
	background_dim.modulate.a = 0.0
	_hide_labels()

func open_map():
	visible = true
	map_container.scale = Vector2(1.0, 1.0)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background_dim, "modulate:a", 0.7, 0.3)
	tween.tween_property(map_container, "modulate:a", 1.0, 0.3)
	tween.finished.connect(_show_labels)

func _return_to_normal():
	var settle = create_tween()
	settle.set_parallel(true)
	settle.set_ease(Tween.EASE_OUT)
	settle.set_trans(Tween.TRANS_SINE)
	settle.tween_property(map_container, "scale", Vector2(1.0, 1.0), BOUNCE_DURATION * 1.5)
	settle.finished.connect(_show_labels)

func close_map():
	_hide_labels()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background_dim, "modulate:a", 0.0, 0.3)
	tween.tween_property(map_container, "modulate:a", 0.0, 0.3)
	tween.finished.connect(_on_close_finished)


func _on_close_finished():
	visible = false
	map_closed.emit()

func _on_close_pressed():
	close_map()

func _on_store_pressed():
	location_selected.emit(STORE_SCENE)

func _on_pond_pressed():
	location_selected.emit(POND_SCENE)

func _on_lake_pressed():
	location_selected.emit(LAKE_SCENE)

func _on_ocean_pressed():
	location_selected.emit(OCEAN_SCENE)
