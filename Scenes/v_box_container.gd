extends VBoxContainer

@onready var start_button: Button = $start
@onready var options_button: Button = $options

func _ready():
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_pressed)

func _on_start_pressed():
	# Change to the game scene
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")

func _on_options_pressed():
	# Change to the options scene
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
