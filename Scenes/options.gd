extends Control

@onready var music_slider: HSlider = $VBoxContainer/MusicContainer/MusicSlider
@onready var music_value_label: Label = $VBoxContainer/MusicContainer/MusicValue
@onready var sfx_slider: HSlider = $VBoxContainer/SFXContainer/SFXSlider
@onready var sfx_value_label: Label = $VBoxContainer/SFXContainer/SFXValue
@onready var back_button: Button = $VBoxContainer/BackButton

var music_bus_index: int
var sfx_bus_index: int

func _ready() -> void:
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	# Initialize sliders with current volumes
	music_slider.value = AudioServer.get_bus_volume_db(music_bus_index)
	sfx_slider.value = AudioServer.get_bus_volume_db(sfx_bus_index)
	
	# Update labels
	music_value_label.text = str(int(music_slider.value))
	sfx_value_label.text = str(int(sfx_slider.value))
	
	# Connect signals
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	back_button.pressed.connect(_on_back_pressed)

func _on_music_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, value)
	music_value_label.text = str(int(value))

func _on_sfx_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, value)
	sfx_value_label.text = str(int(value))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
