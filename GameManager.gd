extends Node

# Player data
var coins: int = 0

signal coins_changed

var owned_upgrades: Dictionary = {
	"rod": 1,
	"hook": 1,
	"area": 1
}

const MAX_LEVELS = {
	"rod": 4,
	"hook": 4,
	"area": 3
}

func get_wait_time() -> float:
	match owned_upgrades["hook"]:
		1: return randf_range(8.0, 12.0)
		2: return randf_range(4.0, 8.0)
		3: return randf_range(2.0, 4.0)
		4: return 1.0
	return randf_range(8.0, 12.0)

func get_fill_speed() -> float:
	match owned_upgrades["rod"]:
		1: return 3.0
		2: return 5.0
		3: return 7.0
		4: return 9.0
	return 3.0

func get_upgrade_price(item_key: String, next_level: int) -> int:
	var base = {
		"rod": 100,
		"hook": 75,
		"area": 200
	}
	var mult = 1.5
	return int(base.get(item_key, 100) * pow(mult, next_level - 2))

func get_level_name(item_key: String, level: int) -> String:
	var names = {
		"rod": {1: "Wooden Rod", 2: "Iron Rod", 3: "Golden Rod", 4: "Master Rod"},
		"hook": {1: "Basic Hook", 2: "Sharp Hook", 3: "Barbed Hook", 4: "Treasure Hook"},
		"area": {1: "Pond Permit", 2: "Lake Permit", 3: "Ocean Permit"}
	}
	return names.get(item_key, {}).get(level, "Unknown")

func upgrade(item_key: String) -> bool:
	var current = owned_upgrades.get(item_key, 1)
	var max_lvl = MAX_LEVELS.get(item_key, 4)
	if current >= max_lvl:
		print("Already max level")
		return false

	var next_lvl = current + 1
	var price = get_upgrade_price(item_key, next_lvl)
	if coins < price:
		print("Not enough coins")
		return false

	coins -= price
	coins_changed.emit()
	owned_upgrades[item_key] = next_lvl
	print("Upgraded %s to level %d" % [item_key, next_lvl])
	return true
	
func sell_fish(fish_data: Dictionary) -> int:
	var value = int(fish_data["weight"] * fish_data["multiplier"] * 10.0)
	coins += value
	coins_changed.emit()
	return value
