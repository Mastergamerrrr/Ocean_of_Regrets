extends Node2D

@onready var fish_sprite: AnimatedSprite2D = $Lake_Fishes_Sprites

const FISH_DATA = [
	{"name": "Perch",          "rarity": "Common",    "multiplier": 1.1},  # frame 0
	{"name": "Largemouth Bass","rarity": "Common",    "multiplier": 1.1},  # frame 1
	{"name": "Pike",           "rarity": "Rare",      "multiplier": 1.2},  # frame 2
	{"name": "Lake Trout",     "rarity": "Epic",      "multiplier": 1.5},  # frame 3
	{"name": "Lake Sturgeon",  "rarity": "Legendary", "multiplier": 2.5},  # frame 4
	{"name": "Abella",         "rarity": "Legendary", "multiplier": 2.5},  # frame 5
]

const RARITY_ENCOUNTER = {
	"Common":    100,
	"Uncommon":  50,
	"Rare":      20,
	"Epic":      8,
	"Legendary": 3
}

var current_fish: Dictionary = {}

func _ready() -> void:
	hide()

func roll_fish() -> Dictionary:
	var pool = []
	for i in FISH_DATA.size():
		var encounter = RARITY_ENCOUNTER[FISH_DATA[i]["rarity"]]
		for j in range(encounter):
			pool.append(i)

	var picked_index = pool[randi() % pool.size()]
	var picked = FISH_DATA[picked_index]
	var fish_weight = snappedf(randf_range(0.1, 4.0), 0.01)

	current_fish = {
		"index":      picked_index,
		"name":       picked["name"],
		"rarity":     picked["rarity"],
		"multiplier": picked["multiplier"],
		"weight":     fish_weight
	}

	fish_sprite.frame = picked_index
	fish_sprite.stop()

	print("Frame index: ", picked_index)
	print("Fish rolled: %s (%s) %.2fkg" % [
		current_fish["name"],
		current_fish["rarity"],
		current_fish["weight"]
	])

	return current_fish

func get_current_fish() -> Dictionary:
	return current_fish
