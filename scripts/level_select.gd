extends Control
class_name LevelSelect

func _ready() -> void:
	var ui := GameUI.canvas(self)
	GameUI.header(ui, "PERJALANAN")
	GameUI.label(ui, "Pilih level", Rect2(88, 174, 370, 64), 46)
	GameUI.paragraph(ui, "Setiap ruang meminta\ncara berpikir yang berbeda.", Rect2(92, 262, 350, 90), 18)
	GameUI.button(ui, "Kembali", Rect2(92, 548, 172, 48), _on_back)
	var details := ["Kunci warna dan suara", "Baca jeda laser", "Lewati wilayah pemburu", "Aktifkan dua pelat bersama", "Rangkaian terakhir"]
	for i in range(5):
		var y := 150.0 + i * 94.0
		var unlocked := i + 1 <= Global.unlocked_level
		GameUI.label(ui, "%02d" % (i + 1), Rect2(526, y + 6, 50, 28), 18, GameUI.MUTED)
		GameUI.label(ui, GameUI.LEVEL_NAMES[i], Rect2(594, y, 370, 34), 23, GameUI.TEXT if unlocked else GameUI.MUTED)
		GameUI.label(ui, details[i], Rect2(594, y + 37, 370, 24), 13, GameUI.MUTED)
		var index := i + 1
		var btn := GameUI.button(ui, "Main" if unlocked else "Terkunci", Rect2(1030, y + 4, 162, 46), func(): _start_level(index))
		btn.disabled = not unlocked
		if i == 0:
			btn.grab_focus()
		if i < 4:
			GameUI.rule(ui, Rect2(526, y + 78, 666, 1), GameUI.LINE)
	GameUI.entrance(ui)

func _start_level(idx: int) -> void:
	Global.current_level_index = idx
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")