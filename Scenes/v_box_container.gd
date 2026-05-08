extends VBoxContainer

@onready var start_button: Button = $start  # Adjust node name if different

func _ready():
	if start_button:
		start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	# Change to the game scene
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
