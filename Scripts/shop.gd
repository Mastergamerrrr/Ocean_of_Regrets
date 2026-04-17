extends Node2D

@onready var interactable: Area2D = $Interactable
@onready var shop_ui = $ShopUI  # We'll create this as a CanvasLayer

func _ready() -> void:
	interactable.interact_name = "Shop"
	interactable.interact = func():
		await open_shop()

func open_shop() -> void:
	shop_ui.show_shop()
	await shop_ui.shop_closed
