extends CanvasLayer
class_name GameOverPopup

signal next_level_requested
signal retry_requested
signal level_select_requested
signal main_menu_requested
var ui: Control
var title_label: Label
var message_label: Label
var status_label: Label
var next_level_btn: Button
var retry_btn: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 21
	ui = GameUI.modal(self, "PERJALANAN", "", "")
	title_label = GameUI.label(ui, "", Rect2(400, 186, 480, 56), 32)
	message_label = GameUI.paragraph(ui, "", Rect2(400, 254, 480, 60), 15)
	status_label = GameUI.label(ui, "", Rect2(400, 550, 480, 24), 12, GameUI.MUTED)
	next_level_btn = GameUI.button(ui, "Lanjutkan", Rect2(400, 330, 480, 54), func(): next_level_requested.emit(), true)
	retry_btn = GameUI.button(ui, "Ulangi level", Rect2(400, 404, 480, 46), func(): retry_requested.emit())
	GameUI.button(ui, "Pilih level", Rect2(400, 470, 230, 46), func(): level_select_requested.emit())
	GameUI.button(ui, "Menu utama", Rect2(650, 470, 230, 46), func(): main_menu_requested.emit())

func show_win(level_idx: int) -> void:
	retry_btn.text = "Ulangi level"
	title_label.text = "Kalian berhasil."
	title_label.add_theme_color_override("font_color", GameUI.CYAN)
	message_label.text = "Labirin %02d berhasil dilewati. Perjalanan kalian belum berakhir." % level_idx
	status_label.text = "LABIRIN %02d / SELESAI" % level_idx
	next_level_btn.visible = level_idx < Global.max_levels
	next_level_btn.text = "Masuk labirin %02d  >" % (level_idx + 1)
	retry_btn.position.y = 404 if next_level_btn.visible else 350
	if level_idx == Global.max_levels:
		message_label.text = "Lima labirin, dua indra, satu kemenangan. Kalian berhasil!"
	visible = true
	if next_level_btn.visible:
		next_level_btn.grab_focus()
	else:
		retry_btn.grab_focus()
	GameUI.entrance(ui)

func show_game_over(reason: String) -> void:
	title_label.text = "Coba sekali lagi."
	title_label.add_theme_color_override("font_color", GameUI.RED)
	message_label.text = reason + " Coba lagi dan temukan jalan yang berbeda."
	status_label.text = "LABIRIN %02d / BELUM SELESAI" % Global.current_level_index
	next_level_btn.visible = false
	retry_btn.position.y = 350
	retry_btn.text = "Coba lagi  >"
	visible = true
	retry_btn.grab_focus()
	GameUI.entrance(ui)
