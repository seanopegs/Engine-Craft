extends Control
class_name MainMenu

@onready var play_btn: Button = $VBox/PlayBtn
@onready var level_select_btn: Button = $VBox/LevelSelectBtn
@onready var guide_btn: Button = $VBox/GuideBtn
@onready var quit_btn: Button = $VBox/QuitBtn

func _ready() -> void:
	play_btn.pressed.connect(_on_play)
	level_select_btn.pressed.connect(_on_level_select)
	guide_btn.pressed.connect(_on_guide)
	quit_btn.pressed.connect(_on_quit)

func _on_play() -> void:
	Global.current_level_index = 1
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_level_select() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_guide() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")

func _on_quit() -> void:
	get_tree().quit()
