extends Node2D
class_name LevelLoader

# Maze Level Loader: Parses raw .txt files into fully playable 2D maze levels

@export var cell_size: float = 56.0

var wall_scene = preload("res://scenes/objects/door.tscn")
var door_scene = preload("res://scenes/objects/door.tscn")
var key_scene = preload("res://scenes/objects/key_item.tscn")
var laser_scene = preload("res://scenes/objects/laser_trap.tscn")
var plate_scene = preload("res://scenes/objects/pressure_plate.tscn")
var exit_scene = preload("res://scenes/objects/exit_portal.tscn")
var monster_scene = preload("res://scenes/entities/monster.tscn")
var blind_char_scene = preload("res://scenes/characters/blind_character.tscn")
var deaf_char_scene = preload("res://scenes/characters/deaf_character.tscn")

var map_width: int = 0
var map_height: int = 0
var wall_cells: Dictionary = {} # Vector2i -> bool
var floor_cells: Array[Vector2i] = []

var blind_character: BlindCharacter = null
var deaf_character: DeafCharacter = null
var monsters: Array[MazeMonster] = []
var exit_portal: ExitPortal = null

# Custom Wall StaticBody
var wall_body: StaticBody2D = null

func load_level_from_file(file_path: String) -> bool:
	# Clear previous children
	for c in get_children():
		c.queue_free()
	wall_cells.clear()
	floor_cells.clear()
	monsters.clear()
	blind_character = null
	deaf_character = null
	exit_portal = null
	
	if not FileAccess.file_exists(file_path):
		printerr("Level file not found: ", file_path)
		return false
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		printerr("Failed to open level file: ", file_path)
		return false
		
	var lines: Array[String] = []
	while not file.eof_reached():
		var line = file.get_line()
		if line.strip_edges().length() > 0:
			lines.append(line)
			
	file.close()
	
	map_height = lines.size()
	map_width = 0
	for line in lines:
		if line.length() > map_width:
			map_width = line.length()
			
	# Create Wall Static Body
	wall_body = StaticBody2D.new()
	wall_body.name = "Walls"
	wall_body.collision_layer = 1
	wall_body.collision_mask = 6
	add_child(wall_body)
	
	var blind_spawn_pos = Vector2.ZERO
	var deaf_spawn_pos = Vector2.ZERO
	var has_blind_spawn = false
	var has_deaf_spawn = false
	
	for y in range(lines.size()):
		var line = lines[y]
		for x in range(line.length()):
			var char_code = line[x]
			var grid_pos = Vector2i(x, y)
			var world_pos = Vector2(x * cell_size + cell_size / 2.0, y * cell_size + cell_size / 2.0)
			
			match char_code:
				"#":
					wall_cells[grid_pos] = true
					var col_shape = CollisionShape2D.new()
					var box = RectangleShape2D.new()
					box.size = Vector2(cell_size, cell_size)
					col_shape.shape = box
					col_shape.position = world_pos
					wall_body.add_child(col_shape)
				".", " ":
					floor_cells.append(grid_pos)
				"P":
					floor_cells.append(grid_pos)
					blind_spawn_pos = world_pos + Vector2(-12, 0)
					deaf_spawn_pos = world_pos + Vector2(12, 0)
					has_blind_spawn = true
					has_deaf_spawn = true
				"A":
					floor_cells.append(grid_pos)
					blind_spawn_pos = world_pos
					has_blind_spawn = true
				"B":
					floor_cells.append(grid_pos)
					deaf_spawn_pos = world_pos
					has_deaf_spawn = true
				"E":
					floor_cells.append(grid_pos)
					var ex = exit_scene.instantiate() as ExitPortal
					ex.position = world_pos
					add_child(ex)
					exit_portal = ex
				"R":
					floor_cells.append(grid_pos)
					var key = key_scene.instantiate() as KeyItem
					key.key_type = KeyItem.KeyType.RED
					key.position = world_pos
					add_child(key)
				"r":
					floor_cells.append(grid_pos)
					var d = door_scene.instantiate() as MazeDoor
					d.door_type = MazeDoor.DoorType.RED
					d.position = world_pos
					add_child(d)
				"S":
					floor_cells.append(grid_pos)
					var key = key_scene.instantiate() as KeyItem
					key.key_type = KeyItem.KeyType.SOUND
					key.position = world_pos
					add_child(key)
				"s":
					floor_cells.append(grid_pos)
					var d = door_scene.instantiate() as MazeDoor
					d.door_type = MazeDoor.DoorType.SOUND
					d.position = world_pos
					add_child(d)
				"K":
					floor_cells.append(grid_pos)
					var key = key_scene.instantiate() as KeyItem
					key.key_type = KeyItem.KeyType.BLUE
					key.position = world_pos
					add_child(key)
				"k":
					floor_cells.append(grid_pos)
					var d = door_scene.instantiate() as MazeDoor
					d.door_type = MazeDoor.DoorType.BLUE
					d.position = world_pos
					add_child(d)
				"L":
					floor_cells.append(grid_pos)
					var laser = laser_scene.instantiate() as LaserTrap
					laser.position = world_pos
					add_child(laser)
				"O":
					floor_cells.append(grid_pos)
					var plate = plate_scene.instantiate() as PressurePlate
					plate.position = world_pos
					add_child(plate)
				"G":
					floor_cells.append(grid_pos)
					var d = door_scene.instantiate() as MazeDoor
					d.door_type = MazeDoor.DoorType.GATE
					d.position = world_pos
					add_child(d)
				"M":
					floor_cells.append(grid_pos)
					var mon = monster_scene.instantiate() as MazeMonster
					mon.position = world_pos
					add_child(mon)
					monsters.append(mon)
					
	# Instantiate Characters
	if has_blind_spawn:
		blind_character = blind_char_scene.instantiate() as BlindCharacter
		blind_character.position = blind_spawn_pos
		add_child(blind_character)
	else:
		blind_character = blind_char_scene.instantiate() as BlindCharacter
		blind_character.position = Vector2(cell_size * 1.5, cell_size * 1.5)
		add_child(blind_character)
		
	if has_deaf_spawn:
		deaf_character = deaf_char_scene.instantiate() as DeafCharacter
		deaf_character.position = deaf_spawn_pos
		add_child(deaf_character)
	else:
		deaf_character = deaf_char_scene.instantiate() as DeafCharacter
		deaf_character.position = Vector2(cell_size * 2.0, cell_size * 1.5)
		add_child(deaf_character)
		
	# Link partner nodes
	blind_character.partner_node = deaf_character
	deaf_character.partner_node = blind_character
	
	queue_redraw()
	return true

func _draw() -> void:
	# Draw Floor Tiles
	var floor_bg_col = Color(0.08, 0.09, 0.12, 1.0)
	var floor_grid_col = Color(0.13, 0.15, 0.2, 0.5)
	
	for pos in floor_cells:
		var r = Rect2(pos.x * cell_size, pos.y * cell_size, cell_size, cell_size)
		draw_rect(r, floor_bg_col, true)
		draw_rect(r, floor_grid_col, false, 1.0)
		
	# Draw Wall Tiles
	var wall_base_col = Color(0.14, 0.16, 0.22, 1.0)
	var wall_top_col = Color(0.2, 0.24, 0.32, 1.0)
	var wall_edge_col = Color(0.3, 0.38, 0.52, 0.8)
	
	for pos in wall_cells.keys():
		var r = Rect2(pos.x * cell_size, pos.y * cell_size, cell_size, cell_size)
		# 3D shadow bevel
		draw_rect(r, wall_base_col, true)
		draw_rect(Rect2(r.position.x + 2, r.position.y + 2, cell_size - 4, cell_size - 4), wall_top_col, true)
		draw_rect(r, wall_edge_col, false, 1.5)
