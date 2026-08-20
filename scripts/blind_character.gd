extends CharacterBase
class_name BlindCharacter

# Blind Character (Kuro): Can hear sound, uses Echolocation sonar pulses
# Screen is dark with glowing sound echoes

var sonar_pulses: Array[Dictionary] = []
var active_pulse_cooldown: float = 0.0
var is_currently_pulsing: bool = false

func _ready() -> void:
	super._ready()
	add_to_group("blind_characters")

func _process(delta: float) -> void:
	if active_pulse_cooldown > 0:
		active_pulse_cooldown -= delta
		
	# Update active sonar waves
	is_currently_pulsing = sonar_pulses.size() > 0
	for i in range(sonar_pulses.size() - 1, -1, -1):
		sonar_pulses[i]["radius"] += delta * 320.0
		sonar_pulses[i]["alpha"] -= delta * 0.75
		
		# Illuminate traps / objects in radius
		_illuminate_nearby(sonar_pulses[i]["radius"])
		
		if sonar_pulses[i]["alpha"] <= 0 or sonar_pulses[i]["radius"] > 450.0:
			sonar_pulses.remove_at(i)
			
	if is_active_character:
		if (Input.is_action_just_pressed("pulse_sonar") or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_E)) and active_pulse_cooldown <= 0:
			trigger_sonar_pulse(true)
			active_pulse_cooldown = 1.0
			
	queue_redraw()

func _on_step() -> void:
	super._on_step()
	if is_active_character:
		# Footstep emits a smaller sonar pulse
		trigger_sonar_pulse(false)

func trigger_sonar_pulse(is_strong: bool) -> void:
	var pulse_data = {
		"radius": 15.0,
		"alpha": 1.0 if is_strong else 0.5,
		"strong": is_strong
	}
	sonar_pulses.append(pulse_data)
	if AudioManager:
		AudioManager.play_sonar_ping(is_strong)

func is_pulsing() -> bool:
	return is_currently_pulsing

func _illuminate_nearby(current_radius: float) -> void:
	var traps = get_tree().get_nodes_in_group("hazards")
	for t in traps:
		if global_position.distance_to(t.global_position) <= current_radius + 40.0:
			if t.has_method("illuminate_by_sonar"):
				t.illuminate_by_sonar()

func _draw() -> void:
	# Active indicator aura
	if is_active_character:
		draw_arc(Vector2(0, 15), 24.0, 0, TAU, 32, Color(0.2, 0.85, 1.0, 0.7), 2.0)
		draw_circle(Vector2(0, 15), 24.0, Color(0.1, 0.7, 1.0, 0.15))
		
		# Draw Sonar Waves expanding from player
		for p in sonar_pulses:
			var col = Color(0.2, 0.85, 1.0, p["alpha"] * 0.8) if p["strong"] else Color(0.4, 0.9, 1.0, p["alpha"] * 0.4)
			var width = 3.0 if p["strong"] else 1.5
			draw_arc(Vector2(0, 10), p["radius"], 0, TAU, 36, col, width)
			# Outer faint ring
			if p["strong"]:
				draw_arc(Vector2(0, 10), p["radius"] * 0.92, 0, TAU, 36, Color(col.r, col.g, col.b, col.a * 0.3), 1.0)
	else:
		draw_arc(Vector2(0, 15), 20.0, 0, TAU, 24, Color(0.6, 0.6, 0.6, 0.4), 1.5)
