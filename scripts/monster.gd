extends CharacterBody2D
class_name MazeMonster

enum State { PATROL, CHASE, SEARCH }

@export var move_speed: float = 100.0
@export var chase_speed: float = 150.0
@export var patrol_direction: Vector2 = Vector2.RIGHT

var current_state: State = State.PATROL
var target_player: Node2D = null

var heartbeat_timer: float = 0.0
var sound_ripples: Array[Dictionary] = []
var eye_pulse: float = 0.0
var patrol_timer: float = 0.0
var change_dir_cooldown: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("monsters")
	if patrol_direction == Vector2.ZERO:
		patrol_direction = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN].pick_random()

func _physics_process(delta: float) -> void:
	eye_pulse += delta * 6.0
	heartbeat_timer += delta
	patrol_timer += delta
	if change_dir_cooldown > 0:
		change_dir_cooldown -= delta
	
	# Emit heartbeat / step ripple every 1.2s
	if heartbeat_timer >= 1.2:
		heartbeat_timer = 0.0
		sound_ripples.append({"radius": 10.0, "alpha": 1.0})
		if AudioManager and not AudioManager.is_deaf_mode:
			AudioManager.play_monster_heartbeat()
			
	# Update sound ripples
	for i in range(sound_ripples.size() - 1, -1, -1):
		sound_ripples[i]["radius"] += delta * 70.0
		sound_ripples[i]["alpha"] -= delta * 0.7
		if sound_ripples[i]["alpha"] <= 0:
			sound_ripples.remove_at(i)
			
	_update_ai(delta)
	move_and_slide()
	
	# Check collision with players
	for i in range(get_slide_collision_count()):
		var coll = get_slide_collision(i)
		var collider = coll.get_collider()
		if collider and collider.is_in_group("players"):
			_catch_player()
			break
			
	queue_redraw()

func _update_ai(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("players")
	var closest_player: Node2D = null
	var min_dist: float = 99999.0
	
	for p in players:
		if p.visible:
			var d = global_position.distance_to(p.global_position)
			if d < min_dist:
				min_dist = d
				closest_player = p
				
	# Detection logic
	if closest_player:
		var has_los = _check_line_of_sight(closest_player)
		var detection_range = 280.0 if has_los else 90.0
		
		# If blind character used sonar pulse nearby, monster hears it!
		if closest_player.has_method("is_pulsing") and closest_player.is_pulsing():
			detection_range = 350.0
			
		if min_dist < detection_range:
			if current_state != State.CHASE:
				current_state = State.CHASE
				if AudioManager:
					AudioManager.play_monster_alert()
			target_player = closest_player
		elif min_dist > 450.0 and current_state == State.CHASE:
			current_state = State.PATROL
			target_player = null
			
	if current_state == State.CHASE and target_player:
		var dir = (target_player.global_position - global_position).normalized()
		velocity = dir * chase_speed
	else:
		# Patrol
		velocity = patrol_direction * move_speed
		if is_on_wall() and change_dir_cooldown <= 0:
			change_dir_cooldown = 0.5
			# Reverse or turn 90 deg
			var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
			dirs.erase(patrol_direction)
			patrol_direction = dirs.pick_random()

func _check_line_of_sight(target: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result:
		return result.collider == target
	return false

func _catch_player() -> void:
	var game_mgr = get_tree().get_first_node_in_group("game_manager")
	if game_mgr and game_mgr.has_method("player_died"):
		game_mgr.player_died("Tertangkap oleh Monster Pemburu!")

func _draw() -> void:
	var is_blind_view = (AudioManager and not AudioManager.is_deaf_mode)
	
	# Draw sound ripples (Visible to Blind / Sound user)
	if is_blind_view:
		for r in sound_ripples:
			var ripple_col = Color(1.0, 0.2, 0.2, r["alpha"] * 0.7)
			draw_arc(Vector2.ZERO, r["radius"], 0, TAU, 28, ripple_col, 2.5)
			
	# Monster body: Dark shadow with pulsing demonic red eyes
	var pulse = (sin(eye_pulse) + 1.0) * 0.2 + 0.8
	var aura_col = Color(0.8, 0.05, 0.05, 0.3 * pulse) if current_state == State.CHASE else Color(0.1, 0.1, 0.15, 0.4)
	
	# Outer shadow aura
	draw_circle(Vector2.ZERO, 26.0, aura_col)
	draw_circle(Vector2.ZERO, 20.0, Color(0.08, 0.05, 0.08, 0.95))
	
	# Glowing red eyes
	var eye_col = Color(1.0, 0.1, 0.1, 1.0 * pulse)
	var dir_offset = velocity.normalized() * 4.0
	draw_circle(Vector2(-6, -4) + dir_offset, 3.5, eye_col)
	draw_circle(Vector2(6, -4) + dir_offset, 3.5, eye_col)
	draw_circle(Vector2(-6, -4) + dir_offset, 1.5, Color.WHITE)
	draw_circle(Vector2(6, -4) + dir_offset, 1.5, Color.WHITE)
	
	# Horns / spikes
	draw_line(Vector2(-12, -10), Vector2(-18, -20), Color(0.2, 0.05, 0.05), 3.0)
	draw_line(Vector2(12, -10), Vector2(18, -20), Color(0.2, 0.05, 0.05), 3.0)
