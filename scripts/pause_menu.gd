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
	ui = GameUI.modal(self, "JEDA", "Tarik napas.", "Perjalanan menunggu.")
	level_label = GameUI.label(ui, "", Rect2(400, 594, 480, 24), 12, GameUI.MUTED)
	resume_btn = GameUI.button(ui, "Lanjutkan", Rect2(400, 330, 480, 54), func(): resume_requested.emit(), true)
	GameUI.button(ui, "Ulangi level", Rect2(400, 404, 480, 46), func(): restart_requested.emit())
	GameUI.button(ui, "Pilih level", Rect2(400, 470, 230, 46), func(): level_select_requested.emit())
	GameUI.button(ui, "Menu utama", Rect2(650, 470, 230, 46), func(): main_menu_requested.emit())
	GameUI.button(ui, "Pengaturan", Rect2(400, 534, 480, 46), func(): GameUI.open_settings(self))
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
