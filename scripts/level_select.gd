extends Control
class_name LevelSelect

func _ready() -> void:
	var ui := GameUI.canvas(self)
	GameUI.header(ui, "PETA PERJALANAN")
	GameUI.label(ui, "Pilih langkah berikutnya.", Rect2(48, 120, 900, 60), 42)
	GameUI.label(ui, "Lima labirin. Saling percaya adalah kunci untuk melangkah lebih jauh.", Rect2(50, 190, 1000, 36), 17, GameUI.MUTED)
	var details := ["Kenali Echo dan Sight.\nPelajari cara saling melengkapi.", "Baca warna. Hindari laser.\nJangan melangkah tanpa arah.", "Dengarkan langkah pemburu.\nBahaya tak selalu terlihat.", "Atur posisi pasangan.\nBuka jalan dengan kerja sama.", "Satukan semua kemampuan.\nTemukan pintu keluar terakhir."]
	var first: Button
	for i in range(5):
		var x := 48.0 + i * 240.0
		var unlocked: bool = i + 1 <= Global.unlocked_level
		var accent := GameUI.CYAN if unlocked else GameUI.MUTED.darkened(0.4)
		GameUI.panel(ui, Rect2(x, 278, 224, 318), accent.darkened(0.5))
		GameUI.rule(ui, Rect2(x + 20, 300, 40, 3), accent)
		GameUI.label(ui, "%02d" % (i + 1), Rect2(x + 20, 328, 184, 74), 58, accent)
		GameUI.label(ui, GameUI.LEVEL_NAMES[i], Rect2(x + 20, 419, 184, 32), 19)
		GameUI.paragraph(ui, details[i], Rect2(x + 20, 462, 184, 60), 13)
		var index := i + 1
		var btn := GameUI.button(ui, "Masuk labirin  >" if unlocked else "Terkunci", Rect2(x + 16, 536, 192, 44), func(): _start_level(index), unlocked)
		btn.disabled = not unlocked
		if i == 0:
			first = btn
	GameUI.button(ui, "<  Menu utama", Rect2(1000, 130, 230, 48), _on_back)
	first.grab_focus()
	GameUI.entrance(ui)

func _start_level(idx: int) -> void:
	Global.current_level_index = idx
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
