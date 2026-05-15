extends Control

@onready var hover_icon = $hovericon
@onready var start_icon_texture = preload("res://Assets/sprites/MAIN MENU/output-onlinepngtools.png")
@onready var options_icon_texture = preload("res://Assets/sprites/MAIN MENU/output-onlinepngtools.png")
@onready var credits_icon_texture = preload("res://Assets/sprites/MAIN MENU/output-onlinepngtools.png")
@onready var quit_icon_texture = preload("res://Assets/sprites/MAIN MENU/output-onlinepngtools.png")

var pulse_tween: Tween
var active_underlines = {}

func _ready():
	# Connect hover signals only for existing buttons
	$VBoxContainer/start.mouse_entered.connect(_on_start_hovered)
	$VBoxContainer/options.mouse_entered.connect(_on_options_hovered)
	$VBoxContainer/credits.mouse_entered.connect(_on_credits_hovered)
	
	# Only connect quit if it exists
	if has_node("VBoxContainer/quit"):
		$VBoxContainer/quit.mouse_entered.connect(_on_quit_hovered)
	
	for button in [$VBoxContainer/start, $VBoxContainer/options, $VBoxContainer/credits]:
		button.mouse_exited.connect(_on_button_unhovered.bind(button))
	
	# Add quit to the list only if it exists
	if has_node("VBoxContainer/quit"):
		$VBoxContainer/quit.mouse_exited.connect(_on_button_unhovered.bind($VBoxContainer/quit))
	
	hover_icon.visible = false
	_setup_button_styles()

func _setup_button_styles():
	for button in [$VBoxContainer/start, $VBoxContainer/options, $VBoxContainer/credits]:
		var button_theme = Theme.new()  # Renamed from 'theme' to avoid shadowing
		button.theme = button_theme
		button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(0.2, 0.8, 0.9, 1))
	
	# Add style for quit button if it exists
	if has_node("VBoxContainer/quit"):
		var quit_theme = Theme.new()
		$VBoxContainer/quit.theme = quit_theme
		$VBoxContainer/quit.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		$VBoxContainer/quit.add_theme_color_override("font_hover_color", Color(0.2, 0.8, 0.9, 1))

func _on_start_hovered():
	hover_icon.texture = start_icon_texture
	show_icon_at($VBoxContainer/start)
	_apply_hover_effect($VBoxContainer/start)

func _on_options_hovered():
	hover_icon.texture = options_icon_texture
	show_icon_at($VBoxContainer/options)
	_apply_hover_effect($VBoxContainer/options)

func _on_credits_hovered():
	hover_icon.texture = credits_icon_texture
	show_icon_at($VBoxContainer/credits)
	_apply_hover_effect($VBoxContainer/credits)

func _on_quit_hovered():
	hover_icon.texture = quit_icon_texture
	show_icon_at($VBoxContainer/quit)
	_apply_hover_effect($VBoxContainer/quit)

func _apply_hover_effect(button: Button):
	# Remove existing underline for this button
	if active_underlines.has(button):
		var old_underline = active_underlines[button]
		if old_underline and is_instance_valid(old_underline):
			old_underline.queue_free()
	
	# Kill existing pulse tween
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	
	# Pulsing glow effect
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(button, "modulate", Color(0.3, 0.9, 1.0, 1), 0.5)
	pulse_tween.tween_property(button, "modulate", Color(0.5, 1.0, 1.0, 1), 0.5)
	
	# Create blinking underline
	_create_underline(button)

func _create_underline(button: Button):
	var underline = Label.new()
	underline.name = "Underline"
	
	# Create underscore string matching text length
	var underscore_text = ""
	for i in range(button.text.length()):
		underscore_text += "_"
	underline.text = underscore_text
	
	underline.add_theme_color_override("font_color", Color(0.2, 0.8, 0.9, 1))
	underline.add_theme_font_size_override("font_size", button.get_theme_font_size("font_size"))
	underline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	button.add_child(underline)
	underline.position = Vector2(6, button.size.y - 23)
	
	active_underlines[button] = underline
	
	# Blinking animation
	var blink_tween = create_tween()
	blink_tween.set_loops()
	blink_tween.tween_property(underline, "modulate:a", 0.2, 0.3)
	blink_tween.tween_property(underline, "modulate:a", 1.0, 0.3)
	
	underline.set_meta("blink_tween", blink_tween)

func show_icon_at(button: Button):
	hover_icon.visible = true
	hover_icon.global_position = Vector2(
		button.global_position.x - hover_icon.size.x - 20,
		button.global_position.y + (button.size.y - hover_icon.size.y) / 2
	)

func _on_button_unhovered(button: Button):
	hover_icon.visible = false
	
	# Kill pulse tween
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	
	# Reset button color
	button.modulate = Color(1, 1, 1, 1)
	
	# Remove underline
	if active_underlines.has(button):
		var underline = active_underlines[button]
		if underline and is_instance_valid(underline):
			if underline.has_meta("blink_tween"):
				var blink = underline.get_meta("blink_tween")
				if blink and blink.is_valid():
					blink.kill()
			underline.queue_free()
		active_underlines.erase(button)
