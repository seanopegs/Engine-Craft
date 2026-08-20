extends Control
class_name HowToPlay

@onready var back_btn: Button = $BackBtn

func _ready() -> void:
	back_btn.pressed.connect(_on_back)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
