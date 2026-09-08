extends CanvasLayer
class_name PauseMenu

signal resume_requested
signal restart_requested
signal level_select_requested
signal main_menu_requested
var ui: Control
var resume_btn: Button
var level_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	ui = GameUI.modal(self, "PERJALANAN DIJEDA", "Tarik napas sejenak.", "Labirin bisa menunggu. Lanjutkan saat kamu siap.")
	GameUI.art(ui, "echo", Rect2(310, 354, 66, 58))
	GameUI.art(ui, "sight", Rect2(400, 354, 66, 58), GameUI.GOLD)
	level_label = GameUI.label(ui, "", Rect2(300, 444, 260, 34), 22)
	GameUI.paragraph(ui, "Dua indra. Satu jalan keluar.\nTetap bersama, temukan jalannya.", Rect2(300, 491, 260, 58), 14)
	resume_btn = GameUI.button(ui, "Lanjutkan perjalanan  >", Rect2(592, 338, 388, 52), func(): resume_requested.emit(), true)
	GameUI.button(ui, "Ulangi level", Rect2(592, 402, 388, 44), func(): restart_requested.emit())
	GameUI.button(ui, "Pilih level", Rect2(592, 458, 188, 44), func(): level_select_requested.emit())
	GameUI.button(ui, "Menu utama", Rect2(792, 458, 188, 44), func(): main_menu_requested.emit())
	GameUI.keycap(ui, "ESC", Rect2(592, 531, 46, 26))
	GameUI.label(ui, "Kembali ke permainan", Rect2(648, 531, 300, 26), 12, GameUI.MUTED)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible and is_instance_valid(ui):
		level_label.text = "LABIRIN %02d / 05" % Global.current_level_index
		resume_btn.grab_focus()
		GameUI.entrance(ui)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		resume_requested.emit()
