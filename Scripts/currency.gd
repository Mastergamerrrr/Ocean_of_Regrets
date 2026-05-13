extends CanvasLayer

@onready var label: Label = $MONEY_KWARTA

var force_hidden: bool = false

const ALLOWED_SCENES = [
	"res://Scenes/game.tscn",
	"res://Scenes/pond_land.tscn",
	"res://Scenes/pond.tscn",
	"res://Scenes/ocean_land.tscn",
	"res://Scenes/ocean.tscn",
	"res://Scenes/lake_land.tscn",
	"res://Scenes/Lake.tscn"
]

func _ready() -> void:
	GameManager.coins_changed.connect(update_display)
	update_display()

func _process(_delta: float) -> void:
	if not force_hidden:
		_check_visibility()

func _check_visibility() -> void:
	var current = get_tree().current_scene
	if current == null or current.scene_file_path == "":
		visible = false
		return
	print("Scene path: ", current.scene_file_path)
	visible = current.scene_file_path in ALLOWED_SCENES

func update_display() -> void:
	label.text = str(GameManager.coins) + "G"
