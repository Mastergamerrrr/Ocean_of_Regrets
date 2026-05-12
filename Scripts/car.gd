extends Node2D
@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var car_door_sound: AudioStreamPlayer = $CarDoorSound
@onready var car_drive_sound: AudioStreamPlayer = $CarDriveSound
@onready var car_stop_sound: AudioStreamPlayer = $CarStopSound

const MAP_SCENE_PATH = "res://Scenes/Map.tscn"
var map_instance: Control = null
var map_canvas: CanvasLayer = null

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	if sprite_2d.frame == 0:
		interactable.is_interactable = false
		get_tree().current_scene.get_node("Player").lock_movement()
		# Play door sound first then open map
		car_door_sound.play()
		await car_door_sound.finished
		_open_map()

func _open_map():
	if map_instance != null:
		map_instance.set_current_location(get_tree().current_scene.scene_file_path)
		map_instance.open_map()
		return
	var map_scene = load(MAP_SCENE_PATH)
	if map_scene == null:
		print("ERROR: Could not load map at: ", MAP_SCENE_PATH)
		return
	map_instance = map_scene.instantiate()
	map_canvas = CanvasLayer.new()
	map_canvas.layer = 1
	map_canvas.add_child(map_instance)
	get_tree().current_scene.add_child(map_canvas)
	if map_instance.has_signal("map_closed"):
		map_instance.map_closed.connect(_on_map_closed)
	if map_instance.has_signal("location_selected"):
		map_instance.location_selected.connect(_on_location_selected)
	
	# Now call after everything is set up
	map_instance.set_current_location(get_tree().current_scene.scene_file_path)
	print("Current scene path: ", get_tree().current_scene.scene_file_path)
	map_instance.open_map()
	
	if map_instance.has_signal("map_closing"):
		map_instance.map_closing.connect(_on_map_closing)
	map_instance.open_map()

func _on_map_closing():
	# Play door sound first
	car_door_sound.play()	
	# Wait for sound then close the map
	await car_door_sound.finished
	map_instance.close_map()

func _on_map_closed():
	interactable.is_interactable = true
	get_tree().current_scene.get_node("Player").unlock_movement()
	print("Map closed, car interactable again.")

func _on_location_selected(scene_path: String):
	print("Traveling to: ", scene_path)
	if map_canvas:
		map_canvas.queue_free()
		map_instance = null
		map_canvas = null
	
	# Clear spawn point so player spawns at default position
	Global.spawn_point = ""
	
	# Show black screen with travelling text
	Transition.show_loading()
	
	car_drive_sound.play()
	await car_drive_sound.finished
	
	car_stop_sound.play()
	await car_stop_sound.finished
	
	Transition.hide_loading()
	Transition.travel_to(scene_path)
