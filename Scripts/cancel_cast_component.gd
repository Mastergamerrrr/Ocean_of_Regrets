extends Node2D

@onready var cancel_label: Label = $CancelCastLabel

func _ready() -> void:
	hide()  # hidden by default

func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("cancel_cast"):
		get_parent()._end_fishing()
		hide()
