extends SceneTree

var failures: int = 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func reachable(lines: PackedStringArray, start: Vector2i, blocked: String) -> Dictionary:
	var visited := {start: 0}
	var queue: Array[Vector2i] = [start]
	var i := 0
	while i < queue.size():
		var cell := queue[i]
		i += 1
		for step in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = cell + step
			if next.y < 0 or next.y >= lines.size() or next.x < 0 or next.x >= lines[0].length():
				continue
			if lines[next.y][next.x] in blocked or visited.has(next):
				continue
			visited[next] = visited[cell] + 1
			queue.append(next)
	return visited

func _initialize() -> void:
	call_deferred("run")

func frames(count: int = 4) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func run() -> void:
	var state := root.get_node("Global")
	var game = load("res://scenes/game_scene.tscn").instantiate()
	root.add_child(game)
	await frames()
	for level in range(1, 6):
		game.start_level(level)
		await frames()
		var loader = game.level_loader
		var lines := FileAccess.get_file_as_string(state.get_level_path(level)).strip_edges().split("\n")
		var typed: Array[String] = []
		typed.assign(lines)
		check(loader.validate_map(typed), "Invalid map %d" % level)
		var points := {}
		for y in range(lines.size()):
			for x in range(lines[y].length()):
				var symbol := lines[y][x]
				if not points.has(symbol):
					points[symbol] = []
				points[symbol].append(Vector2i(x, y))
		var start: Vector2i = points.get("P", points.get("A", []))[0]
		var finish: Vector2i = points.E[0]
		var blocked := "#rs kG".replace(" ", "")
		for iteration in range(6):
			var accessible := reachable(lines, start, blocked)
			for pair in [["R", "r"], ["S", "s"], ["K", "k"]]:
				if points.has(pair[0]) and accessible.has(points[pair[0]][0]):
					blocked = blocked.replace(pair[1], "")
			if points.has("O"):
				check(points.O.size() == 2, "Relay needs exactly two stations")
				if accessible.has(points.O[0]) and accessible.has(points.O[1]):
					check(points.O[0].distance_to(points.O[1]) > 2, "One player could overlap both plates")
					blocked = blocked.replace("G", "")
		var solved := reachable(lines, start, blocked)
		check(solved.has(finish), "Unsolvable progression in level %d" % level)
		for lock in "rskG":
			if points.has(lock):
				check(not reachable(lines, start, "#" + lock).has(finish), "Bypassable door %s in level %d" % [lock, level])
		check(reachable(lines, start, "#").get(finish, 0) >= 40, "Trivial exit path")
		print("Level %d: reachable progression; all doors mandatory; exit distance %d tiles" % [level, reachable(lines, start, "#").get(finish, 0)])
		check(get_nodes_in_group("players").size() == 2, "Restart left old players registered")
		state.is_follow_active = false
		var blind = loader.blind_character
		var deaf = loader.deaf_character
		# A pickup may only occur once, and only for its active owner.
		var key = get_nodes_in_group("keys")[0]
		var owner = deaf if key.key_type == 0 else blind
		var wrong = blind if owner == deaf else deaf
		key._on_body_entered(wrong)
		check(not key.collected, "Wrong character collected a key")
		owner.set_active(true)
		key._on_body_entered(owner)
		key._on_body_entered(owner)
		check(state.keys_collected[key.key_names[key.key_type]] == 1, "Duplicate key pickup")
		owner.set_active(false)
		if points.has("O"):
			var plates := get_nodes_in_group("pressure_plates")
			var gate = get_nodes_in_group("doors").filter(func(d): return d.door_type == 3)[0]
			blind.global_position = plates[0].global_position
			deaf.global_position = Vector2(84, 84)
			await frames()
			check(not gate.is_open, "One plate opened relay")
			deaf.global_position = plates[1].global_position
			await frames()
			check(gate.is_open, "Two plates did not open relay")
			blind.global_position = Vector2(84, 84)
			deaf.global_position = Vector2(84, 84)
			await frames()
			check(gate.is_open, "Relay closed and trapped partner")
		for mon in loader.monsters:
			mon.set_physics_process(false)
		blind.global_position = loader.exit_portal.global_position
		await frames()
		check(not paused, "Single character completed level")
		deaf.global_position = loader.exit_portal.global_position
		await frames()
		check(paused and game.game_over_popup.visible, "Both characters did not complete level")
		paused = false
	# Invalid maps must fail closed.
	var ragged: Array[String] = ["#####", "#P.E#", "####"]
	var open_border: Array[String] = ["##.##", "#P.E#", "#####"]
	check(not game.level_loader.validate_map(ragged), "Ragged map accepted")
	check(not game.level_loader.validate_map(open_border), "Open border accepted")
	var tutorial: Array[String] = []
	tutorial.assign(FileAccess.get_file_as_string("res://levels/level_tutorial.txt").strip_edges().split("\n"))
	check(game.level_loader.validate_map(tutorial), "Invalid tutorial map")
	# A follower must negotiate actual wall collisions around corners.
	game.start_level(1)
	await frames()
	var follower = game.level_loader.deaf_character
	var leader = game.level_loader.blind_character
	leader.global_position = Vector2(196, 196)
	for i in range(180):
		await physics_frame
	check(follower.global_position.distance_to(leader.global_position) < 34, "Follower stuck around a corridor turn")
	# Laser reactivation must hit a stationary player, not only body entry.
	game.start_level(2)
	await frames()
	state.is_follow_active = false
	var laser = get_nodes_in_group("hazards")[0]
	laser.pulse_timer = 3.0
	laser.is_active = false
	game.level_loader.blind_character.global_position = laser.global_position
	await frames()
	check(not paused, "Safe laser interval killed player")
	laser.pulse_timer = 4.99
	await frames()
	check(paused, "Laser reactivation ignored overlapping player")
	paused = false
	# Audio persistence is tested in an isolated config, preserving user settings.
	var settings := root.get_node("GameSettings")
	var saved_volumes: Dictionary = settings.volumes.duplicate()
	var saved_path: String = settings.config_path
	settings.config_path = "res://.godot/settings-test.cfg"
	check(settings.set_volume("Music", 0.23) == OK, "Settings did not save")
	settings.set_volume("SFX", 0.0)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "Zero volume did not mute effects")
	settings.volumes.Music = 1.0
	settings.load_settings()
	check(is_equal_approx(settings.volumes.Music, 0.23), "Music volume did not persist")
	check(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))), 0.23), "Music bus did not apply saved volume")
	settings.volumes = saved_volumes
	settings.config_path = saved_path
	settings.apply_audio()
	DirAccess.remove_absolute("res://.godot/settings-test.cfg")
	game._toggle_pause()
	var settings_menu = load("res://scripts/settings_menu.gd").new()
	game.pause_menu.add_child(settings_menu)
	await frames()
	check(settings_menu.layer > game.pause_menu.layer, "Settings hidden under pause panel")
	settings_menu._close()
	await frames()
	check(paused, "Closing settings resumed gameplay unexpectedly")
	paused = false
	game.queue_free()
	await frames()
	for player in root.get_node("AudioManager")._players:
		player.stop()
		player.stream = null
	await create_timer(0.3).timeout
	print("Verification finished: %d failures" % failures)
	quit(1 if failures else 0)
