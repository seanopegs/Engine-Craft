extends Node

# Global Game State Manager

var current_level_index: int = 1
var max_levels: int = 5
var unlocked_level: int = 1

var keys_collected: Dictionary = {
	"red": 0,
	"sound": 0,
	"blue": 0
}

var character_switch_cooldown: float = 2.5
var is_follow_active: bool = true

func reset_level_state() -> void:
	is_follow_active = true
	keys_collected = {
		"red": 0,
		"sound": 0,
		"blue": 0
	}

func unlock_next_level() -> void:
	if current_level_index + 1 > unlocked_level and unlocked_level < max_levels:
		unlocked_level = current_level_index + 1

func get_level_path(level_idx: int) -> String:
	return "res://levels/level_%d.txt" % level_idx
