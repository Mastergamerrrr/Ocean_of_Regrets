extends Node2D

var can_fish = false
var current_fishing_spot: Area2D = null

@onready var fish_label: Label = $CastLabel
@onready var area: Area2D = $cast_range

func reset() -> void:
	if can_fish:
		var interacting = get_parent().get_node("InteractingComponent")
		if interacting and interacting.current_interactions.size() > 0:
			return  # 👈 don't show if near an interactable
		fish_label.show()

func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	fish_label.hide()

func _on_area_entered(area_hit: Area2D) -> void:
	if area_hit.name == "FishingSpot":
		can_fish = true
		current_fishing_spot = area_hit
		get_parent().current_water_type = area_hit.get_parent().name.to_lower()
		fish_label.show()

func _on_area_exited(area_hit: Area2D) -> void:
	if area_hit.name == "FishingSpot":
		can_fish = false
		current_fishing_spot = null
		fish_label.hide()

func _process(_delta: float) -> void:
	# Hide cast label if player is near an interactable
	var interacting = get_parent().get_node("InteractingComponent")
	if interacting and interacting.current_interactions.size() > 0:
		fish_label.hide()
		return  # 👈 stop here so it doesn't show over interact label

	if can_fish and Input.is_action_just_pressed("Fishing"):
		get_parent()._start_casting()
		fish_label.hide()
	if Input.is_action_just_pressed("cancel_cast"):
		if can_fish:
			fish_label.show()
	
	# Normal show/hide logic
	if can_fish and not get_parent().is_fishing:
		fish_label.show()
	elif not can_fish:
		fish_label.hide()

	if Input.is_action_just_pressed("cancel_cast"):
		if can_fish:
			fish_label.show()  # show again when cancelled
