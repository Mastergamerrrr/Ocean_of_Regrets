extends Node2D

@onready var interactable: Area2D = $Interactable
# Remove @onready var shop_ui = $ShopUI  # We'll instantiate dynamically

func _ready() -> void:
	interactable.interact_name = "Shop"
	interactable.interact = func():
		await open_shop()

func open_shop() -> void:
	# Load the shop UI scene
	var shop_scene = load("res://Scenes/mainshopUI.tscn")
	var shop_ui = shop_scene.instantiate()
	
	# Add to current scene (CanvasLayer will render on top automatically)
	get_tree().current_scene.add_child(shop_ui)
	
	# Pause the game world while shop is open (optional)
	get_tree().paused = true
	
	# Show the shop (if you have an animation or initial setup)
	shop_ui.show_shop()
	
	# Wait for the shop to emit its closed signal
	await shop_ui.shop_closed
	
	# Cleanup
	get_tree().paused = false
	shop_ui.queue_free()
