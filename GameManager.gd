extends Node

# Player data
var coins: int = 2000
var owned_upgrades: Dictionary = {
	"rod": 1,    # 1 = level 1, 2 = level 2, etc.
	"hook": 1,
	"area": 1
}

# Maximum level per item (must match number of icon files and boxes)
const MAX_LEVELS = {
	"rod": 4,
	"hook": 4,
	"area": 3   # permit has only 3 levels
}

# Upgrade price from current level to the next level
func get_upgrade_price(item_key: String, next_level: int) -> int:
	var base = {
		"rod": 100,
		"hook": 75,
		"area": 200
	}
	var mult = 1.5
	return int(base.get(item_key, 100) * pow(mult, next_level - 2))

# The display name for a given level
func get_level_name(item_key: String, level: int) -> String:
	var names = {
		"rod": {1: "Wooden Rod", 2: "Iron Rod", 3: "Golden Rod", 4: "Master Rod"},
		"hook": {1: "Basic Hook", 2: "Sharp Hook", 3: "Barbed Hook", 4: "Treasure Hook"},
		"area": {1: "Pond Permit", 2: "Lake Permit", 3: "Ocean Permit"}
	}
	return names.get(item_key, {}).get(level, "Unknown")

# Buy the next level of an item
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
	owned_upgrades[item_key] = next_lvl
	print("Upgraded %s to level %d" % [item_key, next_lvl])
	return true
