extends Node

enum HookLevel {BASIC, BETTER, BEST}
enum RodLevel {BASIC, BETTER, BEST}

var hook_level: HookLevel = HookLevel.BASIC
var rod_level: RodLevel = RodLevel.BASIC

func get_wait_time() -> float:
	match hook_level:
		HookLevel.BASIC:
			return randf_range(8.0, 12.0)
		HookLevel.BETTER:
			return randf_range(4.0, 8.0)
		HookLevel.BEST:
			return 1.0
	return randf_range(0.0, 12.0)

func get_fill_speed() -> float:
	match rod_level:
		RodLevel.BASIC:
			return 3.0
		RodLevel.BETTER:
			return 6.0
		RodLevel.BEST:
			return 9.0
	return rod_level

func upgrade_hook() -> void:
	if hook_level < HookLevel.BEST:
		hook_level = (hook_level + 1) as HookLevel

func upgrade_rod() -> void:
	if rod_level < RodLevel.BEST:
		rod_level = (rod_level + 1) as RodLevel
