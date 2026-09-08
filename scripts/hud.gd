extends CanvasLayer
class_name GameHUD

var char_name_label: Label
var char_desc_label: Label
var sense_icon: Control
var avatar_panel: Panel
var cooldown_bar: ColorRect
var cooldown_fill: ColorRect
var cooldown_label: Label
var follow_label: Label
var level_label: Label
var level_name: Label
var key_labels: Array[Label] = []
var level_pips: Array[Panel] = []
var key_counts: Array[int] = [-1, -1, -1]
var last_blind: int = -1
var last_level: int = -1
@onready var darkness_overlay: ColorRect = $DarknessOverlay

func _ready() -> void:
	layer = 10
	var ui := GameUI.canvas(self)
	# Compact status cards stay at the edges of the play space.
	GameUI.panel(ui, Rect2(28, 24, 330, 84), GameUI.LINE, Color("101f2a"))
	avatar_panel = GameUI.panel(ui, Rect2(42, 36, 52, 52), GameUI.CYAN.darkened(0.4), Color("122c31"))
	sense_icon = GameUI.art(ui, "echo", Rect2(53, 49, 30, 28))
	GameUI.label(ui, "INDRA AKTIF", Rect2(110, 34, 210, 16), 9, GameUI.MUTED)
	char_name_label = GameUI.label(ui, "ECHO / BUTA", Rect2(108, 50, 230, 26), 22, GameUI.CYAN)
	char_desc_label = GameUI.label(ui, "Dengar jejak monster", Rect2(110, 78, 220, 16), 11, GameUI.MUTED)
	cooldown_bar = ColorRect.new()
	cooldown_bar.position = Vector2(110, 97)
	cooldown_bar.size = Vector2(210, 3)
	cooldown_bar.color = Color("253c47")
	cooldown_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(cooldown_bar)
	cooldown_fill = ColorRect.new()
	cooldown_fill.position = Vector2(110, 97)
	cooldown_fill.size = Vector2(210, 3)
	cooldown_fill.color = GameUI.CYAN
	cooldown_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(cooldown_fill)
	cooldown_label = GameUI.label(ui, "SIAP", Rect2(274, 78, 54, 16), 9, GameUI.CYAN)
	cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	GameUI.panel(ui, Rect2(968, 24, 284, 84), GameUI.LINE, Color("101f2a"))
	level_label = GameUI.label(ui, "LABIRIN 01 / 05", Rect2(988, 35, 244, 16), 9, GameUI.CYAN)
	level_name = GameUI.label(ui, "Dua Indra", Rect2(988, 52, 244, 28), 21)
	for i in range(5):
		level_pips.append(GameUI.panel(ui, Rect2(989 + i * 47, 91, 38, 3), GameUI.LINE, GameUI.LINE))
	GameUI.label(ui, "TUJUAN  /  portal keluar", Rect2(988, 115, 244, 16), 10, GameUI.MUTED)

	# A thin bottom line keeps controls useful without another heavy panel.
	GameUI.rule(ui, Rect2(32, 674, 1216, 1), Color("314852"))
	GameUI.label(ui, "KUNCI", Rect2(32, 687, 42, 16), 10, GameUI.MUTED)
	var colors := [GameUI.RED, GameUI.CYAN, Color("7f9fee")]
	for i in range(3):
		var x := 78.0 + i * 54
		GameUI.art(ui, "key", Rect2(x, 684, 20, 16), colors[i])
		key_labels.append(GameUI.label(ui, "0", Rect2(x + 25, 682, 20, 20), 13))
	GameUI.label(ui, "WASD / PANAH  Gerak", Rect2(270, 682, 190, 20), 11, GameUI.MUTED)
	GameUI.label(ui, "TAB / Q  Ganti indra", Rect2(492, 682, 190, 20), 11, GameUI.MUTED)
	follow_label = GameUI.label(ui, "F  Pasangan mengikuti", Rect2(716, 682, 220, 20), 11, GameUI.CYAN)
	GameUI.label(ui, "ESC  Jeda", Rect2(1114, 682, 118, 20), 11, GameUI.MUTED)
	update_keys_display()
	GameUI.entrance(ui)

func _process(_delta: float) -> void:
	update_keys_display()

func update_hud(is_blind: bool, cooldown_remaining: float, max_cooldown: float, is_following: bool, current_lvl: int) -> void:
	if last_level != current_lvl:
		last_level = current_lvl
		level_label.text = "LABIRIN %02d / 05" % current_lvl
		level_name.text = GameUI.LEVEL_NAMES[clampi(current_lvl - 1, 0, 4)]
		for i in range(5):
			var color := GameUI.CYAN if i < current_lvl else GameUI.LINE
			level_pips[i].add_theme_stylebox_override("panel", GameUI.box(color, color, 1))
	if last_blind != int(is_blind):
		last_blind = int(is_blind)
		var accent := GameUI.CYAN if is_blind else GameUI.GOLD
		char_name_label.text = "ECHO / BUTA" if is_blind else "SIGHT / TULI"
		char_name_label.add_theme_color_override("font_color", accent)
		char_desc_label.text = "Dengar jejak monster" if is_blind else "Lihat warna, kunci & laser"
		sense_icon.mode = "echo" if is_blind else "sight"
		sense_icon.accent = accent
		avatar_panel.add_theme_stylebox_override("panel", GameUI.box(accent.darkened(0.82), accent.darkened(0.5)))
		darkness_overlay.visible = is_blind
	var cooldown_ratio := clampf(1.0 - cooldown_remaining / maxf(max_cooldown, 0.01), 0.0, 1.0)
	cooldown_fill.size.x = 210.0 * cooldown_ratio
	cooldown_label.text = "SIAP" if cooldown_remaining <= 0 else "%.1fs" % cooldown_remaining
	cooldown_label.add_theme_color_override("font_color", GameUI.CYAN if cooldown_remaining <= 0 else GameUI.GOLD)
	follow_label.text = "F  Pasangan mengikuti" if is_following else "F  Pasangan menunggu"
	follow_label.add_theme_color_override("font_color", GameUI.CYAN if is_following else GameUI.GOLD)

func update_keys_display() -> void:
	var types := ["red", "sound", "blue"]
	for i in range(key_labels.size()):
		var count: int = Global.keys_collected.get(types[i], 0)
		if key_counts[i] != count:
			key_labels[i].text = str(count)
			key_counts[i] = count

func _switch() -> void:
	var manager := get_tree().get_first_node_in_group("game_manager")
	if manager and not get_tree().paused and manager.switch_cooldown_timer <= 0:
		manager.switch_character()

func _follow() -> void:
	if not get_tree().paused:
		Global.is_follow_active = not Global.is_follow_active

func _pause() -> void:
	var manager := get_tree().get_first_node_in_group("game_manager")
	if manager and not get_tree().paused:
		manager._toggle_pause()
