extends Control
class_name LevelSelect

@onready var back_btn: Button = $BackBtn
@onready var level_container: VBoxContainer = $CenterContainer/Panel/VBox/LevelButtons

var level_titles = [
	"Level 1: Dua Indra (Tutorial Pengenalan)",
	"Level 2: Laser & Lorong Gelap",
	"Level 3: Sang Pemburu (Monster Intro)",
	"Level 4: Kerjasama Dua Arah (Pressure Plates)",
	"Level 5: Labirin Bayangan (The Grand Labyrinth)"
]

func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	_setup_level_buttons()

func _setup_level_buttons() -> void:
	for i in range(1, Global.max_levels + 1):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(460, 48)
		var is_unlocked = i <= Global.unlocked_level
		btn.disabled = not is_unlocked
		
		var title = level_titles[i - 1]
		if not is_unlocked:
			btn.text = "🔒 " + title + " (Terkunci)"
		else:
			btn.text = "▶ " + title
			
		var lvl_idx = i
		btn.pressed.connect(func(): _start_level(lvl_idx))
		level_container.add_child(btn)

func _start_level(idx: int) -> void:
	Global.current_level_index = idx
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
