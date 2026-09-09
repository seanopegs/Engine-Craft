extends Area2D
class_name KeyItem

enum KeyType { RED, SOUND, BLUE }

@export var key_type: KeyType = KeyType.RED

var key_colors = {
	KeyType.RED: Color(0.95, 0.2, 0.2, 1.0),
	KeyType.SOUND: Color(0.1, 0.85, 1.0, 1.0),
	KeyType.BLUE: Color(0.2, 0.5, 1.0, 1.0)
}

var key_names = {
	KeyType.RED: "red",
	KeyType.SOUND: "sound",
	KeyType.BLUE: "blue"
}

var hover_timer: float = 0.0
var collected: bool = false

func _ready() -> void:
	add_to_group("keys")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	hover_timer += delta * 4.0
	for body in get_overlapping_bodies():
		_on_body_entered(body)
	queue_redraw()

func _draw() -> void:
	# Objects are visible only to the Deaf character.
	# Blind character cannot visually see objects.
	if AudioManager and not AudioManager.is_deaf_mode:
		return
	var col = key_colors[key_type]
	var offset_y = sin(hover_timer) * 4.0
	
	
	# Glow halo
	draw_circle(Vector2(0, offset_y), 18.0, Color(col.r, col.g, col.b, 0.25))
	
	# Draw Key Icon
	if key_type == KeyType.SOUND:
		# Chime / Music note
		draw_circle(Vector2(-4, offset_y + 4), 6.0, col)
		draw_rect(Rect2(0, offset_y - 12, 4, 16), col, true)
		draw_line(Vector2(2, offset_y - 12), Vector2(10, offset_y - 6), col, 4.0)
	else:
		# Classic Skeleton Key
		draw_circle(Vector2(0, offset_y - 6), 8.0, col)
		draw_circle(Vector2(0, offset_y - 6), 4.0, Color.BLACK)
		draw_rect(Rect2(-2, offset_y, 4, 14), col, true)
		draw_rect(Rect2(2, offset_y + 6, 6, 3), col, true)
		draw_rect(Rect2(2, offset_y + 11, 4, 3), col, true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players") and not collected:
		if not body.is_active_character:
			return
		if key_type == KeyType.RED and not body is DeafCharacter:
			return
		if key_type == KeyType.SOUND and not body is BlindCharacter:
			return
		collected = true
		var k_name = key_names[key_type]
		Global.keys_collected[k_name] = Global.keys_collected.get(k_name, 0) + 1
		if AudioManager:
			AudioManager.play_pickup()
		queue_free()
