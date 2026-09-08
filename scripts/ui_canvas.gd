extends Control
## Bound signal disconnects automatically when a scene is freed.
func _ready() -> void:
	get_viewport().size_changed.connect(_fit)
	_fit()

func _fit() -> void:
	var viewport := get_viewport_rect().size
	var factor := minf(viewport.x / 1280.0, viewport.y / 720.0)
	size = Vector2(1280, 720)
	scale = Vector2.ONE * factor
	position = (viewport - size * factor) * 0.5
