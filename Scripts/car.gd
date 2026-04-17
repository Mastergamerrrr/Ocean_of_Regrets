extends Node2D
@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

const MAP_SCENE_PATH = "res://Scenes/Map.tscn"
var map_instance: Control = null
var map_canvas: CanvasLayer = null

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	if sprite_2d.frame == 0:
		interactable.is_interactable = false
		print("car interacted!")
		_open_map()

func _open_map():
	if map_instance != null:
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

	map_instance.open_map()

func _on_map_closed():
	interactable.is_interactable = true
	print("Map closed, car interactable again.")
	# Optional cleanup (uncomment if desired)
	# map_canvas.queue_free()
	# map_instance = null
	# map_canvas = null

func _on_location_selected(scene_path: String):
	print("Traveling to: ", scene_path)
	# Close the map and clean up before changing scene
	if map_canvas:
		map_canvas.queue_free()
		map_instance = null
		map_canvas = null
	
	# Change to the selected scene
	get_tree().change_scene_to_file(scene_path)
