extends CanvasLayer

@onready var pond_fish_sprite: AnimatedSprite2D = $Panel/FishDisplay/PondFishes/Pond_Fishes_Sprites
@onready var lake_fish_sprite: AnimatedSprite2D = $Panel/FishDisplay/LakeFishes/Lake_Fishes_Sprites
@onready var ocean_fish_sprite: AnimatedSprite2D = $Panel/FishDisplay/OceanFishes/Ocean_Fishes_Sprites
@onready var fish_name: Label = $Panel/FishName
@onready var rarity_label: Label = $Panel/Rarity
@onready var weight_label: Label = $Panel/Weight
@onready var value_label: Label = $Panel/Value
@onready var close_button: Button = $Panel/CloseButton
@onready var catch_sound: AudioStreamPlayer2D = $CatchSound  # 👈 make sure this is here

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	$Panel/FishDisplay/PondFishes.hide()
	$Panel/FishDisplay/LakeFishes.hide()
	$Panel/FishDisplay/OceanFishes.hide()

func show_result(fish_data: Dictionary, water_type: String) -> void:
	catch_sound.play()
	$Panel/FishDisplay/PondFishes.hide()
	$Panel/FishDisplay/LakeFishes.hide()
	$Panel/FishDisplay/OceanFishes.hide()
	match water_type:
		"pond":
			pond_fish_sprite.sprite_frames = load("res://Assets/Tres/pond_fish_sprite_frames.tres")
			pond_fish_sprite.frame = fish_data["index"]
			pond_fish_sprite.show()
			$Panel/FishDisplay/PondFishes.show()
		"lake":
			lake_fish_sprite.sprite_frames = load("res://Assets/Tres/lake_fish_sprite_frames.tres")
			lake_fish_sprite.frame = fish_data["index"]
			lake_fish_sprite.show()
			$Panel/FishDisplay/LakeFishes.show()
		"ocean":
			ocean_fish_sprite.sprite_frames = load("res://Assets/Tres/ocean_fish_sprite_frames.tres")
			ocean_fish_sprite.frame = fish_data["index"]
			ocean_fish_sprite.show()
			$Panel/FishDisplay/OceanFishes.show()
	fish_name.text = fish_data["name"]
	rarity_label.text = "Rarity: %s" % fish_data["rarity"]
	weight_label.text = "Weight:  %.2f kg" % fish_data["weight"]
	var value = fish_data["weight"] * fish_data["multiplier"] * 10.0
	value_label.text = "Value:  $%.2f" % value

func _on_close_pressed() -> void:
	queue_free()
