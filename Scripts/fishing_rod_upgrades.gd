extends Node

enum HookLevel {BASIC, BETTER, BEST}
enum RodLevel {BASIC, BETTER, BEST}

var hook_level: HookLevel = HookLevel.BASIC
var rod_level: RodLevel = RodLevel.BASIC


func upgrade_hook() -> void:
	if hook_level < HookLevel.BEST:
		hook_level = (hook_level + 1) as HookLevel

func upgrade_rod() -> void:
	if rod_level < RodLevel.BEST:
		rod_level = (rod_level + 1) as RodLevel
