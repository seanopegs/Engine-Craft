extends Area2D
class_name LaserTrap

@export var is_active: bool = true
var pulse_timer: float = 0.0
var is_detected_by_sonar: bool = false
var sonar_visibility: float = 0.0

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pulse_timer = fmod(pulse_timer + delta, 5.0)
	is_active = pulse_timer < 2.0
	if is_active:
		for body in get_overlapping_bodies():
			_on_body_entered(body)
	if sonar_visibility > 0.0:
		sonar_visibility = maxf(0.0, sonar_visibility - delta * 0.7)
	queue_redraw()

func illuminate_by_sonar() -> void:
	sonar_visibility = 1.0

func _draw() -> void:
	# Objects are visible only to the Deaf character.
	# Blind character cannot visually see objects.
	if AudioManager and not AudioManager.is_deaf_mode:
		return
	if not is_active:
		var warning := pulse_timer > 4.2
		var safe_color := Color(0.95, 0.7, 0.2, 0.8) if warning else Color(0.25, 0.7, 0.5, 0.45)
		draw_rect(Rect2(-24, -24, 48, 48), safe_color, false, 2.0)
		draw_arc(Vector2.ZERO, 12, -PI / 2, -PI / 2 + TAU * (5.0 - pulse_timer) / 3.0, 24, safe_color, 2)
		return
	draw_rect(Rect2(-24, -24, 48, 48), Color(1, 0.1, 0.1, 0.16))
	draw_rect(Rect2(-24, -24, 48, 48), Color(1, 0.2, 0.2, 0.8), false, 2)
	var alpha: float = 0.9
	if AudioManager and not AudioManager.is_deaf_mode:
		# If in blind mode, only visible through sonar illumination
		alpha = maxf(0.05, sonar_visibility)
	
	var pulse = (sin(pulse_timer) + 1.0) * 0.2 + 0.8
	var beam_col = Color(1.0, 0.15, 0.2, alpha * pulse)
	var glow_col = Color(1.0, 0.1, 0.1, alpha * 0.3)
	
	# Emitters
	draw_circle(Vector2(-24, 0), 6.0, Color(0.4, 0.4, 0.5, alpha))
	draw_circle(Vector2(24, 0), 6.0, Color(0.4, 0.4, 0.5, alpha))
	
	# Glow & Core Laser Beam
	draw_line(Vector2(-24, 0), Vector2(24, 0), glow_col, 12.0)
	draw_line(Vector2(-24, 0), Vector2(24, 0), beam_col, 4.0)
	draw_line(Vector2(-24, 0), Vector2(24, 0), Color(1.0, 1.0, 1.0, alpha * 0.8), 1.5)

func _on_body_entered(body: Node2D) -> void:
	if is_active and body.is_in_group("players"):
		if AudioManager:
			AudioManager.play_laser_buzz()
		var game_mgr = get_tree().get_first_node_in_group("game_manager")
		if game_mgr and game_mgr.has_method("player_died"):
			game_mgr.player_died("Terkena Laser Trap!")
