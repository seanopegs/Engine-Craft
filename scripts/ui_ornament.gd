extends Control
## Lightweight vector artwork: no external textures or per-frame allocations of nodes.
var mode: String = "backdrop"
var accent: Color = Color("65e3d5")
var phase: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	phase += delta * 0.35
	queue_redraw()

func _draw() -> void:
	var c := size * 0.5
	if mode == "echo":
		for i in range(5):
			var h := (0.28 + 0.5 * absf(sin(phase * 4.0 + i * 0.9))) * size.y
			draw_line(Vector2(size.x * (0.18 + i * 0.16), c.y - h / 2), Vector2(size.x * (0.18 + i * 0.16), c.y + h / 2), accent, 3.0, true)
	elif mode == "sight":
		var upper := PackedVector2Array()
		var lower := PackedVector2Array()
		for i in range(25):
			var t := i / 24.0
			upper.append(Vector2(size.x * (0.05 + t * 0.9), c.y - sin(t * PI) * size.y * 0.28))
			lower.append(Vector2(size.x * (0.05 + t * 0.9), c.y + sin(t * PI) * size.y * 0.28))
		draw_polyline(upper, accent, 2.0, true)
		draw_polyline(lower, accent, 2.0, true)
		draw_circle(c, size.x * 0.13, accent)
	elif mode == "key":
		draw_arc(Vector2(size.x * 0.3, c.y), size.y * 0.19, 0, TAU, 20, accent, 2.0, true)
		draw_line(Vector2(size.x * 0.48, c.y), Vector2(size.x * 0.86, c.y), accent, 2.0, true)
		draw_line(Vector2(size.x * 0.75, c.y), Vector2(size.x * 0.75, c.y + 5), accent, 2.0, true)
	elif mode == "backdrop":
		draw_rect(Rect2(Vector2.ZERO, size), Color("101416"))
	elif mode == "duet":
		var left := c - Vector2(45, 0)
		var right := c + Vector2(45, 0)
		draw_arc(left, 92, 0, TAU, 100, Color(0.72, 0.83, 0.77, 0.25), 1.5, true)
		draw_arc(right, 92, 0, TAU, 100, Color(0.84, 0.78, 0.64, 0.25), 1.5, true)
		draw_circle(left, 7, accent)
		draw_circle(right, 7, Color("d6c7a3"))
	elif mode == "maze":
		var origin := Vector2(30, 25)
		var cell := 44.0
		for y in range(10):
			for x in range(11):
				var p := origin + Vector2(x, y) * cell
				if (x * 7 + y * 3) % 5 < 2:
					draw_rect(Rect2(p, Vector2(cell - 4, cell - 4)), Color("142430"))
					draw_line(p, p + Vector2(cell - 4, 0), Color("2c4550"), 1)
		var path := PackedVector2Array([Vector2(52, 420), Vector2(140, 420), Vector2(140, 244), Vector2(316, 244), Vector2(316, 112), Vector2(448, 112)])
		draw_polyline(path, Color(0.4, 0.9, 0.83, 0.08), 16, true)
		draw_polyline(path, Color(0.4, 0.9, 0.83, 0.5), 2, true)
		for i in range(3):
			var radius := 24.0 + fmod(phase * 24 + i * 33, 100.0)
			draw_arc(Vector2(140, 244), radius, 0, TAU, 64, Color(0.4, 0.9, 0.83, (124 - radius) / 300.0), 1, true)
		draw_circle(Vector2(140, 244), 8, accent)
		draw_circle(Vector2(316, 112), 8, Color("efbc72"))
		draw_arc(Vector2(448, 112), 17, phase, phase + PI * 1.7, 32, Color("efbc72"), 2, true)
		draw_circle(Vector2(448, 112), 4, Color("efbc72"))
