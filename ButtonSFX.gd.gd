extends Node

var click_sound : AudioStream
var _player : AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)
	click_sound = preload("res://Assets/sounds/computer-mouse-click-352734.mp3")
	get_tree().node_added.connect(_on_node_added)
	_connect_all_buttons(get_tree().root)

func _on_node_added(node: Node) -> void:
	if node is Button or node is TextureButton or node is LinkButton:
		node.pressed.connect(_play_click.bind(node))

func _connect_all_buttons(node: Node) -> void:
	if node is Button or node is TextureButton or node is LinkButton:
		node.pressed.connect(_play_click.bind(node))
	for child in node.get_children():
		_connect_all_buttons(child)

func _play_click(button: Node) -> void:
	if button.is_in_group("no_sfx"):
		return
	if click_sound:
		_player.stream = click_sound
		_player.play()
