extends StaticBody2D
class_name MazeDoor

enum DoorType { RED, SOUND, BLUE, GATE }

@export var door_type: DoorType = DoorType.RED
@export var is_open: bool = false

var door_colors = {
	DoorType.RED: Color(0.95, 0.2, 0.2, 1.0),
	DoorType.SOUND: Color(0.1, 0.85, 1.0, 1.0),
	DoorType.BLUE: Color(0.2, 0.5, 1.0, 1.0),
	DoorType.GATE: Color(0.8, 0.7, 0.2, 1.0)
}

var door_names = {
	DoorType.RED: "red",
	DoorType.SOUND: "sound",
	DoorType.BLUE: "blue",
	DoorType.GATE: "gate"
}

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var glow_timer: float = 0.0

func _ready() -> void:
	add_to_group("doors")
	update_state()

func _process(delta: float) -> void:
	glow_timer += delta * 3.0
	queue_redraw()

func _draw() -> void:
	# Objects are visible only to the Deaf character.
	# Blind character cannot visually see objects.
	if AudioManager and not AudioManager.is_deaf_mode:
		return
	if is_open:
		# Draw faint open threshold
		var base_col = door_colors[door_type]
		draw_rect(Rect2(-28, -28, 56, 56), Color(base_col.r, base_col.g, base_col.b, 0.15), true)
		draw_rect(Rect2(-28, -28, 56, 56), Color(base_col.r, base_col.g, base_col.b, 0.4), false, 2.0)
		return
		
	var col = door_colors[door_type]
	var pulse = (sin(glow_timer) + 1.0) * 0.15 + 0.7
	
	# Solid door frame
	draw_rect(Rect2(-28, -28, 56, 56), Color(0.12, 0.12, 0.16, 1.0), true)
	draw_rect(Rect2(-28, -28, 56, 56), col * pulse, false, 3.0)
	
	# Inner pattern
	if door_type == DoorType.GATE:
		# Gate bars
		for i in range(-20, 25, 10):
			draw_line(Vector2(i, -24), Vector2(i, 24), col * pulse, 3.0)
	elif door_type == DoorType.SOUND:
		# Sound wave symbol
		draw_arc(Vector2.ZERO, 14.0, -PI/2, PI/2, 16, col * pulse, 3.0)
		draw_arc(Vector2.ZERO, 8.0, -PI/2, PI/2, 12, col * pulse, 3.0)
		draw_circle(Vector2(-4, 0), 4.0, col * pulse)
	else:
		# Keyhole / lock icon
		draw_circle(Vector2(0, -6), 8.0, col * pulse)
		draw_rect(Rect2(-4, -6, 8, 16), col * pulse, true)

func try_unlock(player_char) -> bool:
	if is_open or door_type == DoorType.GATE:
		return false
		
	var key_type = door_names[door_type]
	if Global.keys_collected.get(key_type, 0) > 0:
		Global.keys_collected[key_type] -= 1
		open_door()
		if AudioManager:
			AudioManager.play_door_open()
		return true
	return false

func open_door() -> void:
	is_open = true
	update_state()

func close_door() -> void:
	is_open = false
	update_state()

func set_gate_open(open_state: bool) -> void:
	if door_type == DoorType.GATE:
		if is_open != open_state:
			is_open = open_state
			update_state()
			if AudioManager:
				AudioManager.play_door_open()

func update_state() -> void:
	if collision_shape:
		collision_shape.set_deferred("disabled", is_open)
	queue_redraw()
