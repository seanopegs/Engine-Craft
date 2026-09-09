extends CanvasLayer

var status: Label
var sliders: Dictionary = {}
var previous_focus: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30
	previous_focus = get_viewport().gui_get_focus_owner()
	var dimmer := ColorRect.new()
	dimmer.color = Color(0.025, 0.03, 0.035, 0.94)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dimmer)
	var ui := GameUI.canvas(self)
	GameUI.panel(ui, Rect2(352, 72, 576, 576))
	GameUI.label(ui, "Pengaturan", Rect2(400, 106, 480, 56), 34)
	status = GameUI.label(ui, "Perubahan tersimpan otomatis.", Rect2(400, 169, 480, 24), 13, GameUI.MUTED)
	var names := ["Volume utama", "Musik", "Efek suara"]
	var buses := ["Master", "Music", "SFX"]
	for i in range(3):
		var y := 218.0 + i * 78
		var bus: String = buses[i]
		GameUI.label(ui, names[i], Rect2(400, y, 330, 26), 16)
		var value_label := GameUI.label(ui, "%d%%" % roundi(GameSettings.volumes[bus] * 100), Rect2(800, y, 80, 26), 14, GameUI.MUTED)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var slider := HSlider.new()
		slider.position = Vector2(400, y + 32)
		slider.size = Vector2(480, 24)
		slider.max_value = 100
		slider.step = 1
		slider.value = GameSettings.volumes[bus] * 100
		var track := GameUI.box(GameUI.LINE, GameUI.LINE, 3)
		var fill := GameUI.box(GameUI.CYAN, GameUI.CYAN, 3)
		for style in [track, fill]:
			style.content_margin_top = 3
			style.content_margin_bottom = 3
			style.content_margin_left = 0
			style.content_margin_right = 0
		slider.add_theme_stylebox_override("slider", track)
		slider.add_theme_stylebox_override("grabber_area", fill)
		ui.add_child(slider)
		sliders[bus] = slider
		slider.value_changed.connect(func(value):
			value_label.text = "%d%%" % roundi(value)
			_save_status(GameSettings.set_volume(bus, value / 100.0)))
	var fullscreen := CheckButton.new()
	fullscreen.text = "Layar penuh"
	fullscreen.position = Vector2(400, 466)
	fullscreen.size = Vector2(260, 40)
	fullscreen.button_pressed = GameSettings.fullscreen
	fullscreen.add_theme_font_size_override("font_size", 16)
	ui.add_child(fullscreen)
	fullscreen.toggled.connect(func(enabled): _save_status(GameSettings.set_fullscreen(enabled)))
	GameUI.button(ui, "Tes suara", Rect2(706, 466, 174, 40), func(): AudioManager.play_plate_click())
	GameUI.button(ui, "Reset suara", Rect2(400, 550, 220, 48), _reset_audio)
	var back := GameUI.button(ui, "Selesai", Rect2(640, 550, 240, 48), _close, true)
	back.grab_focus()
	GameUI.entrance(ui)

func _save_status(error: Error) -> void:
	status.text = "Perubahan tersimpan otomatis." if error == OK else "Pengaturan berlaku, tetapi gagal disimpan."

func _reset_audio() -> void:
	for bus in sliders:
		sliders[bus].value = GameSettings.DEFAULTS[bus] * 100

func _close() -> void:
	if is_instance_valid(previous_focus):
		previous_focus.grab_focus()
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_close()
