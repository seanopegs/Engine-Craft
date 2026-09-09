extends Control
class_name HowToPlay

func _ready() -> void:
	var ui := GameUI.canvas(self)
	GameUI.header(ui, "PANDUAN")
	GameUI.label(ui, "Temukan jalan bersama.", Rect2(88, 135, 1000, 66), 44)
	GameUI.paragraph(ui, "Bawa kedua karakter ke portal. Ganti indra untuk membaca ruang.", Rect2(92, 218, 1050, 36), 18)
	GameUI.label(ui, "Echo", Rect2(92, 300, 480, 42), 28, GameUI.CYAN)
	GameUI.paragraph(ui, "Mendeteksi pemburu dan mengambil kunci suara.\nGanti ke Sight untuk melihat benda dan laser.", Rect2(92, 356, 500, 88), 17)
	GameUI.label(ui, "Sight", Rect2(688, 300, 480, 42), 28, GameUI.GOLD)
	GameUI.paragraph(ui, "Melihat jalur dan mengambil kunci merah.\nGanti ke Echo untuk mengetahui posisi pemburu.", Rect2(688, 356, 500, 88), 17)
	GameUI.rule(ui, Rect2(92, 466, 1100, 1))
	GameUI.paragraph(ui, "WASD / Panah   Gerak       Tab / Q   Ganti       F   Ikuti / tunggu       Esc   Jeda", Rect2(92, 494, 1100, 36), 16)
	GameUI.paragraph(ui, "Laser: hijau aman, kuning bersiap, merah berbahaya.\nPelat: matikan ikuti, tempatkan satu karakter di tiap pelat. Gerbang tetap terbuka.", Rect2(92, 550, 1090, 64), 15)
	var back := GameUI.button(ui, "Kembali", Rect2(1020, 632, 172, 44), _on_back)
	back.grab_focus()
	GameUI.entrance(ui)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")