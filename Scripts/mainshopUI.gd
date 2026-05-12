extends CanvasLayer

signal shop_closed

# ---- Icon references ----
@onready var rod_icon: TextureRect = $Control/ItemSlotRod/rod
@onready var hook_icon: TextureRect = $Control/ItemSlotHook/hook
@onready var permit_icon: TextureRect = $Control/ItemSlotPermit/permit

# ---- Upgrade indicator containers ----
@onready var rod_indicator: HBoxContainer = $Control/UpgradeIndicatorRod
@onready var hook_indicator: HBoxContainer = $Control/UpgradeIndicatorHook
@onready var permit_indicator: HBoxContainer = $Control/UpgradeIndicatorPermit

# ---- Upgrade buttons ----
@onready var rod_btn: Button = $Control/RodUpgrade
@onready var hook_btn: Button = $Control/HookUpgrade
@onready var permit_btn: Button = $Control/PermitUpgrade

# ---- New dynamic labels ----
@onready var rod_level_name: Label = $Control/RodLevelName
@onready var hook_level_name: Label = $Control/HookLevelName
@onready var permit_level_name: Label = $Control/PermitLevelName

@onready var rod_upgrade_cost: Label = $Control/RodUpgradeCost
@onready var hook_upgrade_cost: Label = $Control/HookUpgradeCost
@onready var permit_upgrade_cost: Label = $Control/PermitUpgradeCost

# ---- Gold label ----
@onready var gold_amount: Label = $Control/Coins/amount

# ---- Leave button ----
@onready var leave_button: Button = $Control/LeaveButton

# ---- Fill color for boxes ----
const FILL_COLOR = Color(0.847, 0.651, 0.227)   # #D8A63A warm gold

func _ready():
	if leave_button:
		leave_button.pressed.connect(close_shop)
	process_mode = PROCESS_MODE_ALWAYS
	hide()

# ---------------------
# Shop opening
# ---------------------
func show_shop():
	# Disconnect previous connections to avoid duplicates
	if rod_btn.pressed.is_connected(handle_rod_upgrade):
		rod_btn.pressed.disconnect(handle_rod_upgrade)
	rod_btn.pressed.connect(handle_rod_upgrade)
	
	if hook_btn.pressed.is_connected(handle_hook_upgrade):
		hook_btn.pressed.disconnect(handle_hook_upgrade)
	hook_btn.pressed.connect(handle_hook_upgrade)
	
	if permit_btn.pressed.is_connected(handle_permit_upgrade):
		permit_btn.pressed.disconnect(handle_permit_upgrade)
	permit_btn.pressed.connect(handle_permit_upgrade)
	
	var rod_lvl = GameManager.owned_upgrades["rod"]
	var hook_lvl = GameManager.owned_upgrades["hook"]
	var permit_lvl = GameManager.owned_upgrades["area"]
	
	_update_indicator(rod_indicator, rod_lvl)
	_update_indicator(hook_indicator, hook_lvl)
	_update_indicator(permit_indicator, permit_lvl)
	
	rod_icon.texture = _get_icon("rod", rod_lvl)
	hook_icon.texture = _get_icon("hook", hook_lvl)
	permit_icon.texture = _get_icon("permit", permit_lvl)
	
	_update_button_state(rod_btn, rod_lvl, "rod")
	_update_button_state(hook_btn, hook_lvl, "hook")
	_update_button_state(permit_btn, permit_lvl, "area")
	
	_update_level_name(rod_level_name, "rod", rod_lvl)
	_update_level_name(hook_level_name, "hook", hook_lvl)
	_update_level_name(permit_level_name, "area", permit_lvl)
	
	_update_upgrade_cost(rod_upgrade_cost, "rod", rod_lvl)
	_update_upgrade_cost(hook_upgrade_cost, "hook", hook_lvl)
	_update_upgrade_cost(permit_upgrade_cost, "area", permit_lvl)
	
	gold_amount.text = str(GameManager.coins)
	show()

# ---------------------
# Direct upgrade handlers (no _attempt_upgrade needed)
# ---------------------
func handle_rod_upgrade():
	if GameManager.upgrade("rod"):
		var lvl = GameManager.owned_upgrades["rod"]
		_update_indicator(rod_indicator, lvl)
		rod_icon.texture = _get_icon("rod", lvl)
		gold_amount.text = str(GameManager.coins)
		_update_button_state(rod_btn, lvl, "rod")
		_update_level_name(rod_level_name, "rod", lvl)
		_update_upgrade_cost(rod_upgrade_cost, "rod", lvl)

func handle_hook_upgrade():
	if GameManager.upgrade("hook"):
		var lvl = GameManager.owned_upgrades["hook"]
		_update_indicator(hook_indicator, lvl)
		hook_icon.texture = _get_icon("hook", lvl)
		gold_amount.text = str(GameManager.coins)
		_update_button_state(hook_btn, lvl, "hook")
		_update_level_name(hook_level_name, "hook", lvl)
		_update_upgrade_cost(hook_upgrade_cost, "hook", lvl)

func handle_permit_upgrade():
	print("Permit upgrade button pressed!")
	if GameManager.upgrade("area"):
		var lvl = GameManager.owned_upgrades["area"]
		print("New level: ", lvl)
		_update_indicator(permit_indicator, lvl)
		var tex = _get_icon("permit", lvl)
		print("Setting permit icon to: ", tex)
		permit_icon.texture = tex
		gold_amount.text = str(GameManager.coins)
		_update_button_state(permit_btn, lvl, "area")
		_update_level_name(permit_level_name, "area", lvl)
		_update_upgrade_cost(permit_upgrade_cost, "area", lvl)
	else:
		print("Upgrade failed (not enough coins or max level)")

# ---------------------
# Indicator fill logic
# ---------------------
func _update_indicator(indicator: HBoxContainer, level: int):
	var boxes = indicator.get_children()
	for i in range(boxes.size()):
		var box: ColorRect = boxes[i]
		box.color = FILL_COLOR if i < level else Color.TRANSPARENT

# ---------------------
# Icon resolver
# ---------------------
func _get_icon(item_key: String, level: int) -> Texture2D:
	var folder: String
	var prefix: String
	match item_key:
		"rod":
			folder = "res://Assets/sprites/shop ui assets/fishrod upgrades/"
			prefix = "fishRodLvl"
		"hook":
			folder = "res://Assets/sprites/shop ui assets/hook upgrades/"
			prefix = "hookLvl"
		"permit":
			folder = "res://Assets/sprites/shop ui assets/permit upgrades/"
			prefix = "permitLvl"
		_:
			return null

	for lvl in range(level, 0, -1):
		var path = folder + prefix + str(lvl) + ".tres"
		print("Searching: ", path)
		if ResourceLoader.exists(path):
			var tex = load(path)
			if tex is Texture2D and tex.get_width() > 0:
				print("  -> Valid texture found (", tex.get_width(), "x", tex.get_height(), ")")
				return tex
			else:
				print("  -> File exists but texture is EMPTY or invalid, skipping...")
		else:
			print("  -> File not found")

	for lvl in range(level, 0, -1):
		var path = folder + prefix + str(lvl) + ".png"
		print("Searching PNG: ", path)
		if ResourceLoader.exists(path):
			var tex = load(path) as Texture2D
			if tex and tex.get_width() > 0:
				print("  -> Valid PNG texture found")
				return tex

	printerr("❌ No valid icon found for ", item_key, " up to level ", level)
	return null

# ---------------------
# Dynamic label updates
# ---------------------
func _update_level_name(label: Label, item_key: String, level: int):
	label.text = GameManager.get_level_name(item_key, level)

func _update_upgrade_cost(label: Label, item_key: String, current_level: int):
	var max_lvl = GameManager.MAX_LEVELS.get(item_key, 4)
	if current_level >= max_lvl:
		label.text = "MAX"
	else:
		var next_lvl = current_level + 1
		var price = GameManager.get_upgrade_price(item_key, next_lvl)
		label.text = "Upgrade: %dG" % price

# ---------------------
# Button state (MAX if maxed, enable/disable)
# ---------------------
func _update_button_state(btn: Button, current_lvl: int, item_key: String):
	var max_lvl = GameManager.MAX_LEVELS.get(item_key, 4)
	if current_lvl >= max_lvl:
		btn.text = "MAXED"
		btn.disabled = true
	else:
		btn.text = "UPGRADE"
		btn.disabled = false

# ---------------------
# Close shop
# ---------------------
func close_shop():
	shop_closed.emit()
	hide()

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		close_shop()
		get_viewport().set_input_as_handled()
