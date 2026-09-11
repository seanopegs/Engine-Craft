extends Control

func _ready() -> void:
	var ending: bool = Global.story_is_epilogue
	var ui := GameUI.canvas(self)
	GameUI.header(ui, "AFTER THE END")
	GameUI.label(ui, "SETELAH EVAKUASI" if not ending else "SETELAH LABIRIN", Rect2(92, 146, 900, 30), 13, GameUI.CYAN)
	GameUI.label(ui, "Kalian tertinggal." if not ending else "Besok dimulai bersama.", Rect2(88, 198, 1080, 72), 46)
	var story := "Evakuasi kota telah berakhir. Lorong bawah tanah sudah ditinggalkan, tetapi Echo dan Sight belum keluar.\n\nEcho tidak dapat melihat objek di sekitarnya. Sight tidak dapat mendengar petunjuk suara. Mereka harus saling melengkapi untuk melewati pintu, laser, dan pemburu yang masih berada di lorong.\n\nLima labirin memisahkan mereka dari permukaan. Temukan jalan keluar, dan bawa keduanya pulang."
	if ending:
		story = "Untuk pertama kalinya sejak evakuasi berakhir, Echo dan Sight mencapai permukaan bersama. Lorong terakhir telah mereka lewati.\n\nKota yang mereka kenal sudah ditinggalkan. Jalan pulang yang lama berakhir di sini, tetapi kini mereka dapat mencari tempat tinggal baru.\n\nMereka tidak tahu apa yang menanti esok. Mereka tahu siapa yang akan berjalan di samping mereka."
	var body := GameUI.paragraph(ui, "", Rect2(92, 286, 1040, 260), 19, GameUI.TEXT)
	body.text = story
	GameUI.label(ui, "Engine Craft  /  Aset visual dan musik: Cello", Rect2(92, 570, 1040, 26), 14, GameUI.MUTED)
	var proceed := GameUI.button(ui, "Kembali ke menu" if ending else "Cari jalan bersama  >", Rect2(92, 624, 360, 52), _continue, true)
	if not ending:
		GameUI.button(ui, "Lewati cerita", Rect2(984, 624, 208, 52), _continue)
	proceed.grab_focus()
	GameUI.entrance(ui)

func _continue() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn" if Global.story_is_epilogue else "res://scenes/game_scene.tscn")
