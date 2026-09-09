extends Control
class_name MainMenu

func _ready() -> void:
	var ui := GameUI.canvas(self)
	GameUI.art(ui, "backdrop", Rect2(0, 0, 1280, 720))
	GameUI.label(ui, "E N G I N E   C R A F T", Rect2(88, 56, 400, 24), 12, GameUI.MUTED)
	GameUI.label(ui, "Echo & Sight", Rect2(88, 204, 780, 94), 68)
	GameUI.paragraph(ui, "Dua indra. Satu perjalanan.", Rect2(92, 316, 600, 36), 21)
	var play := GameUI.button(ui, "Mulai perjalanan", Rect2(92, 412, 300, 56), _on_play, true)
	GameUI.button(ui, "Pilih level", Rect2(92, 488, 144, 44), _on_level_select)
	GameUI.button(ui, "Panduan", Rect2(252, 488, 140, 44), _on_guide)
	GameUI.button(ui, "Pengaturan", Rect2(92, 550, 300, 44), func(): GameUI.open_settings(self))
	GameUI.art(ui, "duet", Rect2(800, 220, 320, 280), GameUI.CYAN)
	GameUI.button(ui, "Keluar", Rect2(1060, 610, 132, 44), _on_quit)
	GameUI.label(ui, "Petualangan puzzle untuk dua karakter.", Rect2(92, 624, 650, 24), 13, GameUI.MUTED)
	play.grab_focus()
	GameUI.entrance(ui)

func _on_play() -> void:
	Global.current_level_index = mini(Global.unlocked_level, Global.max_levels)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_level_select() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_guide() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")

func _on_quit() -> void:
	get_tree().quit()
