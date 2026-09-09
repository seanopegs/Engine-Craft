extends CanvasLayer
class_name GameHUD

var character_label: Label
var switch_label: Label
var level_label: Label
var objective_label: Label
var inventory_label: Label
var follow_label: Label
@onready var darkness_overlay: ColorRect = $DarknessOverlay

func _ready() -> void:
	layer = 10
	var ui := GameUI.canvas(self)
	GameUI.panel(ui, Rect2(24, 20, 240, 66), GameUI.LINE, GameUI.INK)
	character_label = GameUI.label(ui, "Echo", Rect2(42, 26, 110, 30), 21, GameUI.CYAN)
	switch_label = GameUI.label(ui, "Tab · ganti", Rect2(42, 59, 200, 18), 11, GameUI.MUTED)
	level_label = GameUI.label(ui, "", Rect2(852, 28, 400, 32), 17)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	GameUI.panel(ui, Rect2(24, 614, 1232, 86), GameUI.LINE, GameUI.INK)
	objective_label = GameUI.label(ui, "", Rect2(44, 625, 1180, 26), 15)
	inventory_label = GameUI.label(ui, "", Rect2(44, 661, 390, 20), 12, GameUI.MUTED)
	follow_label = GameUI.label(ui, "", Rect2(480, 661, 370, 20), 12, GameUI.MUTED)
	GameUI.label(ui, "WASD  Gerak     Esc  Jeda", Rect2(1000, 661, 240, 20), 12, GameUI.MUTED)

func update_hud(is_blind: bool, cooldown: float, _max_cooldown: float, following: bool, level: int) -> void:
	character_label.text = "Echo" if is_blind else "Sight"
	character_label.add_theme_color_override("font_color", GameUI.CYAN if is_blind else GameUI.GOLD)
	switch_label.text = "Tab / Q   Ganti indra" if cooldown <= 0 else "Ganti dalam %.1f dtk" % cooldown
	darkness_overlay.visible = is_blind
	level_label.text = "%02d   %s" % [level, GameUI.LEVEL_NAMES[clampi(level - 1, 0, 4)]]
	follow_label.text = "F   Pasangan mengikuti" if following else "F   Pasangan menunggu"
	inventory_label.text = "Kunci   Merah %d   Suara %d   Biru %d" % [Global.keys_collected.red, Global.keys_collected.sound, Global.keys_collected.blue]
	var locked := 0
	var relay := false
	for door in get_tree().get_nodes_in_group("doors"):
		if not door.is_open:
			locked += 1
			relay = relay or door.door_type == MazeDoor.DoorType.GATE
	if relay:
		objective_label.text = "Aktifkan kedua pelat bersamaan · F untuk menahan posisi pasangan."
	elif locked > 0:
		objective_label.text = "Buka %d pintu lagi · Merah: Sight. Kunci suara: Echo." % locked
	else:
		objective_label.text = "Jalur terbuka · Bawa Echo dan Sight bersama ke portal."
	var portal := get_tree().get_first_node_in_group("exit_portals")
	if portal and portal.get_overlapping_bodies().size() == 1:
		objective_label.text = "Satu karakter sudah tiba · Jemput pasangan untuk menyelesaikan level."