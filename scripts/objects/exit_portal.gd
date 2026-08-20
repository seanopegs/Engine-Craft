extends Area2D
class_name ExitPortal

var spin_timer: float = 0.0

func _ready() -> void:
	add_to_group("exit_portals")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	spin_timer += delta * 3.0
	queue_redraw()

func _draw() -> void:
	var pulse = (sin(spin_timer * 2.0) + 1.0) * 0.2 + 0.8
	var portal_col = Color(0.2, 0.95, 0.5, 0.8 * pulse)
	
	# Glow rings
	draw_circle(Vector2.ZERO, 26.0 * pulse, Color(0.2, 0.95, 0.5, 0.2))
	draw_arc(Vector2.ZERO, 22.0, 0, TAU, 32, portal_col, 3.0)
	draw_arc(Vector2.ZERO, 15.0, spin_timer, spin_timer + PI, 24, Color(1.0, 1.0, 0.4, 0.8), 2.5)
	draw_arc(Vector2.ZERO, 9.0, -spin_timer, -spin_timer + PI, 16, Color.WHITE, 2.0)
	draw_circle(Vector2.ZERO, 4.0, Color.WHITE)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		var game_mgr = get_tree().get_first_node_in_group("game_manager")
		if game_mgr and game_mgr.has_method("level_completed"):
			game_mgr.level_completed()
