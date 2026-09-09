extends Area2D
class_name PressurePlate

var is_pressed: bool = false
var bodies_on_plate: int = 0

signal plate_state_changed(pressed: bool)

func _ready() -> void:
	add_to_group("pressure_plates")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# Objects are visible only to the Deaf character.
	# Blind character cannot visually see objects.
	if AudioManager and not AudioManager.is_deaf_mode:
		return
	var bg_col = Color(0.2, 0.2, 0.25, 1.0)
	var plate_col = Color(0.3, 0.8, 0.3, 1.0) if is_pressed else Color(0.85, 0.7, 0.2, 1.0)
	var size = 44.0 if not is_pressed else 40.0
	
	draw_rect(Rect2(-24, -24, 48, 48), bg_col, true)
	draw_rect(Rect2(-size/2, -size/2, size, size), plate_col, true)
	draw_rect(Rect2(-24, -24, 48, 48), Color.WHITE * 0.4, false, 2.0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		bodies_on_plate += 1
		if not is_pressed:
			is_pressed = true
			if AudioManager:
				AudioManager.play_plate_click()
			plate_state_changed.emit(true)
			_update_gates(true)
			queue_redraw()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		bodies_on_plate = maxi(0, bodies_on_plate - 1)
		if bodies_on_plate == 0 and is_pressed:
			is_pressed = false
			plate_state_changed.emit(false)
			_update_gates(false)
			queue_redraw()

func _update_gates(state: bool) -> void:
	# A cooperative relay latches permanently once BOTH stations are held.
	# Releasing one station cannot trap the other character behind a gate.
	if not state:
		return
	var plates := get_tree().get_nodes_in_group("pressure_plates")
	if plates.size() < 2:
		return
	for plate in plates:
		if not plate.is_pressed:
			return
	var gates = get_tree().get_nodes_in_group("doors")
	for g in gates:
		if g.has_method("set_gate_open"):
			g.set_gate_open(true)
