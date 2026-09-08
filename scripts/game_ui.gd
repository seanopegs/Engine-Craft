extends RefCounted
class_name GameUI

const INK := Color("0c1520")
const PANEL := Color("111f2b")
const LINE := Color("304550")
const TEXT := Color("e3ecea")
const MUTED := Color("91a6ad")
const CYAN := Color("65e3d5")
const GOLD := Color("efbc72")
const RED := Color("ef7f85")
const ORNAMENT = preload("res://scripts/ui_ornament.gd")
const LEVEL_NAMES := ["Dua Indra", "Lorong Gelap", "Sang Pemburu", "Dua Arah", "Labirin Bayangan"]

static func canvas(parent: Node) -> Control:
	var root := Control.new()
	root.set_script(preload("res://scripts/ui_canvas.gd"))
	root.name = "Interface"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(root)
	return root

static func box(color: Color = PANEL, border: Color = LINE, radius: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

static func panel(parent: Node, rect: Rect2, border: Color = LINE, color: Color = PANEL) -> Panel:
	var node := Panel.new()
	node.position = rect.position
	node.size = rect.size
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_stylebox_override("panel", box(color, border))
	parent.add_child(node)
	return node

static func label(parent: Node, value: String, rect: Rect2, font_size: int = 16, color: Color = TEXT) -> Label:
	var node := Label.new()
	node.text = value
	node.position = rect.position
	node.size = rect.size
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

static func paragraph(parent: Node, value: String, rect: Rect2, font_size: int = 16, color: Color = MUTED) -> Label:
	var node := label(parent, value, rect, font_size, color)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	return node

static func rule(parent: Node, rect: Rect2, color: Color = LINE) -> void:
	var node := ColorRect.new()
	node.position = rect.position
	node.size = rect.size
	node.color = color
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)

static func art(parent: Node, mode: String, rect: Rect2, accent: Color = CYAN) -> Control:
	var node := Control.new()
	node.set_script(ORNAMENT)
	node.mode = mode
	node.accent = accent
	node.position = rect.position
	node.size = rect.size
	parent.add_child(node)
	return node

static func button(parent: Node, value: String, rect: Rect2, callback: Callable, primary: bool = false) -> Button:
	var node := Button.new()
	node.text = value
	node.position = rect.position
	node.size = rect.size
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.alignment = HORIZONTAL_ALIGNMENT_LEFT
	node.add_theme_font_size_override("font_size", 17)
	node.add_theme_color_override("font_color", INK if primary else TEXT)
	node.add_theme_color_override("font_hover_color", INK if primary else CYAN)
	node.add_theme_color_override("font_pressed_color", INK if primary else CYAN)
	node.add_theme_color_override("font_focus_color", INK if primary else CYAN)
	node.add_theme_color_override("font_disabled_color", MUTED.darkened(0.3))
	node.add_theme_stylebox_override("normal", box(CYAN if primary else PANEL, CYAN if primary else LINE, 6))
	node.add_theme_stylebox_override("hover", box(CYAN.lightened(0.15) if primary else Color("1b303b"), CYAN, 6))
	node.add_theme_stylebox_override("pressed", box(CYAN.darkened(0.15) if primary else Color("243b45"), CYAN, 6))
	node.add_theme_stylebox_override("disabled", box(Color("0d1721"), Color("21333e"), 6))
	var focus := box(Color.TRANSPARENT, GOLD, 6)
	focus.set_border_width_all(2)
	node.add_theme_stylebox_override("focus", focus)
	parent.add_child(node)
	node.pressed.connect(callback)
	return node

static func keycap(parent: Node, value: String, rect: Rect2) -> void:
	panel(parent, rect, Color("405560"), Color("1a2b36"))
	var text := label(parent, value, rect, 12, TEXT)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func portrait(parent: Node, blind: bool, rect: Rect2) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = load("res://assets/blind.png" if blind else "res://assets/deaf.png")
	texture.region = Rect2(0, 0, 271, 539) if blind else Rect2(0, 0, 272, 541)
	var node := TextureRect.new()
	node.texture = texture
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.position = rect.position
	node.size = rect.size
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)

static func header(root: Control, section: String) -> void:
	art(root, "backdrop", Rect2(0, 0, 1280, 720))
	art(root, "echo", Rect2(42, 32, 28, 24))
	label(root, "ENGINE / CRAFT", Rect2(84, 26, 260, 36), 18)
	var section_label := label(root, section, Rect2(870, 30, 368, 30), 12, MUTED)
	section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label(root, "ECHO & SIGHT", Rect2(42, 674, 260, 25), 12, MUTED)
	var footer := label(root, "DUA INDRA. SATU JALAN KELUAR.", Rect2(750, 674, 488, 25), 11, MUTED)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

static func entrance(node: Control) -> void:
	node.modulate.a = 0.0
	var tween := node.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(node, "modulate:a", 1.0, 0.25)

static func modal(parent: CanvasLayer, eyebrow: String, heading: String, subtitle: String) -> Control:
	var dimmer := ColorRect.new()
	dimmer.color = Color(0.015, 0.03, 0.05, 0.88)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(dimmer)
	var root := canvas(parent)
	panel(root, Rect2(260, 118, 760, 484))
	rule(root, Rect2(260, 118, 760, 2), CYAN)
	label(root, eyebrow, Rect2(300, 150, 620, 24), 12, CYAN)
	label(root, heading, Rect2(300, 184, 620, 56), 38)
	paragraph(root, subtitle, Rect2(300, 248, 620, 52), 15)
	rule(root, Rect2(300, 312, 680, 1))
	return root
