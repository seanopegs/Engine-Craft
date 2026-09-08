extends Control
class_name HowToPlay

func _ready() -> void:
	var ui := GameUI.canvas(self)
	GameUI.header(ui, "PANDUAN PENJELAJAH")
	GameUI.label(ui, "Saling melengkapi.", Rect2(48, 112, 850, 64), 42)
	GameUI.label(ui, "Ganti karakter, kumpulkan kunci, dan temukan portal keluar.", Rect2(50, 178, 1000, 36), 17, GameUI.MUTED)
	var back := GameUI.button(ui, "<  Menu utama", Rect2(1000, 126, 230, 48), _on_back)
	for i in range(2):
		var x := 48.0 + i * 600.0
		var color := GameUI.CYAN if i == 0 else GameUI.GOLD
		GameUI.panel(ui, Rect2(x, 242, 584, 244), color.darkened(0.5))
		GameUI.art(ui, "echo" if i == 0 else "sight", Rect2(x + 26, 270, 44, 44), color)
		GameUI.label(ui, "ECHO / BUTA" if i == 0 else "SIGHT / TULI", Rect2(x + 90, 264, 440, 38), 25, color)
		GameUI.label(ui, "ANDALKAN PENDENGARAN" if i == 0 else "ANDALKAN PENGLIHATAN", Rect2(x + 90, 304, 440, 24), 11, GameUI.MUTED)
		GameUI.paragraph(ui, "Lokasi monster terungkap lewat suara.\nPenglihatan terbatas; laser, kunci, dan pintu tersembunyi.\nGanti ke Sight sebelum melewati jalur berbahaya." if i == 0 else "Lihat laser, kunci, dan pintu dengan jelas.\nSuara dan lokasi monster tidak dapat kamu tangkap.\nGanti ke Echo untuk mengetahui posisi pemburu.", Rect2(x + 28, 352, 528, 100), 16)
	GameUI.panel(ui, Rect2(48, 510, 1184, 130))
	var keys := ["WASD / PANAH", "TAB / Q", "F", "ESC"]
	var titles := ["Bergerak", "Ganti karakter", "Ikuti / tunggu", "Jeda permainan"]
	var notes := ["Jelajahi labirin", "Isi ulang 2,5 detik", "Tahan posisi di pelat tekan", "Lanjut, ulang, atau pilih level"]
	for i in range(4):
		var x := 72.0 + i * 294.0
		GameUI.keycap(ui, keys[i], Rect2(x, 530, 122 if i == 0 else 76, 28))
		GameUI.label(ui, titles[i], Rect2(x, 566, 266, 28), 16)
		GameUI.label(ui, notes[i], Rect2(x, 598, 266, 24), 12, GameUI.MUTED)
	back.grab_focus()
	GameUI.entrance(ui)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
