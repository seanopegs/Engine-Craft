extends CharacterBase
class_name DeafCharacter

# Deaf Character (Shiro): Full sight, sees all visual traps, color doors
# Cannot hear audio/sonar cues

func _ready() -> void:
	super._ready()
	add_to_group("deaf_characters")

func _draw() -> void:
	if is_active_character:
		draw_arc(Vector2(0, 15), 24.0, 0, TAU, 32, Color(1.0, 0.8, 0.2, 0.8), 2.0)
		draw_circle(Vector2(0, 15), 24.0, Color(1.0, 0.8, 0.2, 0.15))
	else:
		draw_arc(Vector2(0, 15), 20.0, 0, TAU, 24, Color(0.6, 0.6, 0.6, 0.4), 1.5)
