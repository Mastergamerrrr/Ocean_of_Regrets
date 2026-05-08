extends CanvasLayer

signal shop_closed

@onready var leave_button: Button = $LeaveButton

func _ready():
	if leave_button:
		leave_button.pressed.connect(close_shop)
	hide()
	process_mode = PROCESS_MODE_ALWAYS

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		close_shop()
		get_viewport().set_input_as_handled()

func show_shop():
	show()

func close_shop():
	shop_closed.emit()
	hide()
