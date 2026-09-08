extends Control
class_name MainMenu

func _ready() -> void:
	var ui := GameUI.canvas(self)
	GameUI.art(ui, "backdrop", Rect2(0, 0, 1280, 720))
	GameUI.art(ui, "echo", Rect2(52, 32, 28, 24))
	GameUI.label(ui, "ENGINE / CRAFT", Rect2(92, 26, 240, 36), 18)
	var build := GameUI.label(ui, "ECHO & SIGHT  /  01", Rect2(960, 31, 268, 26), 11, GameUI.MUTED)
	build.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# One quiet card keeps the start screen focused on the game title and its actions.
	GameUI.panel(ui, Rect2(360, 118, 560, 484), GameUI.LINE, Color("0d1822"))
	GameUI.rule(ui, Rect2(400, 158, 480, 2), GameUI.CYAN)
	GameUI.label(ui, "A CO-OP MAZE OF PERCEPTION", Rect2(400, 182, 480, 22), 11, GameUI.CYAN)
	GameUI.label(ui, "ECHO & SIGHT", Rect2(400, 214, 480, 62), 46)
	var subtitle := GameUI.paragraph(ui, "Dua karakter. Dua cara melihat dunia.\nBekerja sama untuk menemukan jalan keluar.", Rect2(400, 288, 480, 56), 16)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	GameUI.rule(ui, Rect2(440, 366, 400, 1), GameUI.LINE)
	var play := GameUI.button(ui, "Mulai permainan   >", Rect2(470, 394, 340, 50), _on_play, true)
	GameUI.button(ui, "Pilih level", Rect2(470, 456, 164, 44), _on_level_select)
	GameUI.button(ui, "Cara bermain", Rect2(646, 456, 164, 44), _on_guide)
	GameUI.label(ui, "ECHO  /  dengar yang tak terlihat", Rect2(400, 535, 230, 20), 11, GameUI.CYAN)
	var sight := GameUI.label(ui, "SIGHT  /  lihat yang tak terdengar", Rect2(650, 535, 230, 20), 11, GameUI.GOLD)
	sight.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var quit := GameUI.button(ui, "Keluar", Rect2(1076, 30, 152, 36), _on_quit)
	quit.add_theme_font_size_override("font_size", 13)
	play.grab_focus()
	GameUI.entrance(ui)

func _on_play() -> void:
	Global.current_level_index = 1
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_level_select() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_guide() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")

func _on_quit() -> void:
	get_tree().quit()
