extends CanvasLayer

signal shop_closed

# ─── Upgrade Costs ───────────────────────────────────────────────
const ROD_COSTS   := [100, 250, 500, 1000]
const HOOK_COSTS  := [150, 300, 600, 1200]
const AREA_COSTS  := [200, 400, 800, 1500]

const ROD_NAMES   := ["Wooden Rod", "Iron Rod", "Golden Rod", "Crystal Rod"]
const HOOK_NAMES  := ["Basic Hook", "Sharp Hook", "Barbed Hook", "Mythic Hook"]
const AREA_NAMES  := ["Pond", "Lake", "Ocean", "Abyss"]

# ─── Persistent player data (connect to your PlayerData singleton) ─
var rod_level  := 0
var hook_level := 0
var area_level := 0
var gold       := 1000

# ─── UI References ───────────────────────────────────────────────
@onready var panel: PanelContainer = $Panel
@onready var rod_label: Label = $Panel/VBox/RodRow/RodLabel
@onready var rod_cost_label: Label = $Panel/VBox/RodRow/RodCostLabel
@onready var rod_button: Button = $Panel/VBox/RodRow/RodButton
@onready var hook_label: Label = $Panel/VBox/HookRow/HookLabel
@onready var hook_cost_label: Label = $Panel/VBox/HookRow/HookCostLabel
@onready var hook_button: Button = $Panel/VBox/HookRow/HookButton
@onready var area_label: Label = $Panel/VBox/AreaRow/AreaLabel
@onready var area_cost_label: Label = $Panel/VBox/AreaRow/AreaCostLabel
@onready var area_button: Button = $Panel/VBox/AreaRow/AreaButton
@onready var gold_label: Label = $Panel/VBox/GoldLabel
@onready var close_button: Button = $CloseButton

func _ready() -> void:
	panel.hide()
	close_button.hide()
	rod_button.pressed.connect(_on_upgrade_rod)
	hook_button.pressed.connect(_on_upgrade_hook)
	area_button.pressed.connect(_on_upgrade_area)
	close_button.pressed.connect(_on_close)
	
	# ── If you have a PlayerData autoload, load from it here ──
	# gold       = PlayerData.gold
	# rod_level  = PlayerData.rod_level
	# hook_level = PlayerData.hook_level
	# area_level = PlayerData.area_level

func show_shop() -> void:
	_refresh_ui()
	panel.show()
	close_button.show()

func _on_close() -> void:
	panel.hide()
	close_button.hide()
	emit_signal("shop_closed")

# ─── Upgrade Handlers ────────────────────────────────────────────
func _on_upgrade_rod() -> void:
	if rod_level >= ROD_COSTS.size(): return
	if gold >= ROD_COSTS[rod_level]:
		gold -= ROD_COSTS[rod_level]
		rod_level += 1
		# PlayerData.rod_level = rod_level
		_refresh_ui()

func _on_upgrade_hook() -> void:
	if hook_level >= HOOK_COSTS.size(): return
	if gold >= HOOK_COSTS[hook_level]:
		gold -= HOOK_COSTS[hook_level]
		hook_level += 1
		# PlayerData.hook_level = hook_level
		_refresh_ui()

func _on_upgrade_area() -> void:
	if area_level >= AREA_COSTS.size(): return
	if gold >= AREA_COSTS[area_level]:
		gold -= AREA_COSTS[area_level]
		area_level += 1
		# PlayerData.area_level = area_level
		_refresh_ui()

# ─── UI Refresh ──────────────────────────────────────────────────
func _refresh_ui() -> void:
	gold_label.text = "Gold: %d" % gold

	_refresh_row(rod_label,  rod_cost_label,  rod_button,
				 ROD_NAMES,  ROD_COSTS,  rod_level,  "Rod")
	_refresh_row(hook_label, hook_cost_label, hook_button,
				 HOOK_NAMES, HOOK_COSTS, hook_level, "Hook")
	_refresh_row(area_label, area_cost_label, area_button,
				 AREA_NAMES, AREA_COSTS, area_level, "Area")

func _refresh_row(name_lbl: Label, cost_lbl: Label, btn: Button,
				  names: Array, costs: Array,
				  level: int, category: String) -> void:
	name_lbl.text = "%s: %s" % [category, names[min(level, names.size()-1)]]
	if level >= costs.size():
		cost_lbl.text = "MAX"
		btn.disabled = true
	else:
		cost_lbl.text = "%d G" % costs[level]
		btn.disabled = (gold < costs[level])
