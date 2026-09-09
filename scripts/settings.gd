extends Node

const DEFAULTS := {"Master": 0.75, "Music": 0.65, "SFX": 0.8}
var volumes: Dictionary = DEFAULTS.duplicate()
var fullscreen: bool = false
var config_path: String = "user://settings.cfg"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			var index := AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus)
			AudioServer.set_bus_send(index, "Master")
	load_settings()
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(config_path) == OK:
		for bus in DEFAULTS:
			var value = config.get_value("audio", bus, DEFAULTS[bus])
			volumes[bus] = clampf(float(value), 0, 1) if (value is float or value is int) and is_finite(float(value)) else DEFAULTS[bus]
		fullscreen = config.get_value("display", "fullscreen", false) == true
	apply_audio()

func apply_audio() -> void:
	for bus in volumes:
		var index := AudioServer.get_bus_index(bus)
		if index >= 0:
			AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volumes[bus], 0.0001)))
			AudioServer.set_bus_mute(index, volumes[bus] <= 0)

func save_settings() -> Error:
	var config := ConfigFile.new()
	for bus in volumes:
		config.set_value("audio", bus, volumes[bus])
	config.set_value("display", "fullscreen", fullscreen)
	return config.save(config_path)

func set_volume(bus: String, value: float) -> Error:
	if not DEFAULTS.has(bus):
		return ERR_INVALID_PARAMETER
	volumes[bus] = clampf(value, 0, 1)
	apply_audio()
	return save_settings()

func set_fullscreen(enabled: bool) -> Error:
	fullscreen = enabled
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
	return save_settings()
