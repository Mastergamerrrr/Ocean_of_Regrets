extends Control

@onready var hover_icon = $hovericon
@onready var start_icon_texture = preload("res://Assets/sprites/MAIN MENU/output-onlinepngtools.png")
@onready var options_icon_texture = preload("res://Assets/sprites/MAIN MENU/output-onlinepngtools.png")
@onready var quit_icon_texture = preload("res://Assets/sprites/MAIN MENU/output-onlinepngtools.png")

func _ready():
	$VBoxContainer/start.mouse_entered.connect(_on_start_hovered)
	$VBoxContainer/options.mouse_entered.connect(_on_options_hovered)
	$VBoxContainer/credits.mouse_entered.connect(_on_quit_hovered)
	
	for button in [$VBoxContainer/start, $VBoxContainer/options, $VBoxContainer/credits]:
		button.mouse_exited.connect(_on_button_unhovered)
	
	hover_icon.visible = false

func _on_start_hovered():
	hover_icon.texture = start_icon_texture
	show_icon_at($VBoxContainer/start)

func _on_options_hovered():
	hover_icon.texture = options_icon_texture
	show_icon_at($VBoxContainer/options)

func _on_quit_hovered():
	hover_icon.texture = quit_icon_texture
	show_icon_at($VBoxContainer/credits)

func show_icon_at(button: Button):
	hover_icon.visible = true
	hover_icon.global_position = Vector2(
		button.global_position.x - hover_icon.size.x - 20,
		button.global_position.y + (button.size.y - hover_icon.size.y) / 2
	)

func _on_button_unhovered():
	hover_icon.visible = false
