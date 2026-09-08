extends CharacterBase
class_name BlindCharacter

# Blind Character (Kuro): Can hear sound, but has no sonar ability.

func _ready() -> void:
	super._ready()
	add_to_group("blind_characters")
