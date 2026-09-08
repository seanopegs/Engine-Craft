extends Node2D
class_name GameManager

@onready var level_loader: LevelLoader = $LevelLoader
@onready var camera: Camera2D = $Camera2D
@onready var hud: GameHUD = $HUD
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_popup: GameOverPopup = $GameOverPopup
var theme_song: AudioStreamPlayer
var theme_song_stream: AudioStream = preload("res://assets/Engine Craft Theme Song.mp3")

var is_blind_active: bool = true
var switch_cooldown_timer: float = 0.0
var max_switch_cooldown: float = 2.5

var is_level_active: bool = false

func _ready() -> void:
	add_to_group("game_manager")
	
	pause_menu.resume_requested.connect(_on_resume)
	pause_menu.restart_requested.connect(_on_restart_level)
	pause_menu.level_select_requested.connect(_on_goto_level_select)
	pause_menu.main_menu_requested.connect(_on_goto_main_menu)
	
	game_over_popup.next_level_requested.connect(_on_next_level)
	game_over_popup.retry_requested.connect(_on_restart_level)
	game_over_popup.level_select_requested.connect(_on_goto_level_select)
	game_over_popup.main_menu_requested.connect(_on_goto_main_menu)
	
	# Create the level theme player once. It is restarted whenever a level starts.
	theme_song = AudioStreamPlayer.new()
	theme_song.name = "EngineCraftTheme"
	theme_song.stream = theme_song_stream
	theme_song.bus = "Master"
	add_child(theme_song)
	if theme_song.stream is AudioStreamMP3:
		theme_song.stream.loop = true

	start_level(Global.current_level_index)

func start_level(level_idx: int) -> void:
	get_tree().paused = false
	pause_menu.visible = false
	game_over_popup.visible = false
	
	Global.current_level_index = level_idx
	Global.reset_level_state()

	# Play/restart Engine-Craft theme whenever a level begins.
	if theme_song:
		theme_song.play()
	
	var file_path = Global.get_level_path(level_idx)
	var success = level_loader.load_level_from_file(file_path)
	if not success:
		printerr("Could not load level: ", file_path)
		return
		
	# Start with Blind character active
	is_blind_active = true
	switch_cooldown_timer = 0.0
	_update_active_character_state(false)
	
	if level_loader.blind_character:
		camera.global_position = level_loader.blind_character.global_position
		
	is_level_active = true

func _process(delta: float) -> void:
	if not is_level_active or get_tree().paused:
		return
		
	if switch_cooldown_timer > 0.0:
		switch_cooldown_timer -= delta
		
	_handle_input()
	_update_camera(delta)
	
	# Update HUD
	if hud:
		hud.update_hud(is_blind_active, switch_cooldown_timer, max_switch_cooldown, Global.is_follow_active, Global.current_level_index)

func _handle_input() -> void:
	# Pause
	if Input.is_action_just_pressed("pause") or Input.is_key_pressed(KEY_ESCAPE):
		_toggle_pause()
		return
		
	# Switch Character
	if (Input.is_action_just_pressed("switch_char") or Input.is_key_pressed(KEY_TAB) or Input.is_key_pressed(KEY_Q)) and switch_cooldown_timer <= 0:
		switch_character()
		
	# Toggle Follow Mode
	if Input.is_action_just_pressed("toggle_follow") or Input.is_key_pressed(KEY_F):
		Global.is_follow_active = not Global.is_follow_active
		if AudioManager:
			AudioManager.play_plate_click()

func switch_character() -> void:
	is_blind_active = not is_blind_active
	switch_cooldown_timer = max_switch_cooldown
	_update_active_character_state(true)

func _update_active_character_state(play_sound: bool = true) -> void:
	if not level_loader:
		return
		
	if level_loader.blind_character:
		level_loader.blind_character.set_active(is_blind_active)
	if level_loader.deaf_character:
		level_loader.deaf_character.set_active(not is_blind_active)
		
	# Audio deaf filter
	if AudioManager:
		AudioManager.is_deaf_mode = not is_blind_active
		if play_sound:
			AudioManager.play_switch()

func _update_camera(delta: float) -> void:
	var target_pos = Vector2.ZERO
	if is_blind_active and level_loader.blind_character:
		target_pos = level_loader.blind_character.global_position
	elif not is_blind_active and level_loader.deaf_character:
		target_pos = level_loader.deaf_character.global_position
		
	if target_pos != Vector2.ZERO:
		camera.global_position = camera.global_position.lerp(target_pos, delta * 7.0)

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused

func _on_resume() -> void:
	get_tree().paused = false
	pause_menu.visible = false

func _on_restart_level() -> void:
	start_level(Global.current_level_index)

func _on_next_level() -> void:
	if Global.current_level_index < Global.max_levels:
		start_level(Global.current_level_index + 1)
	else:
		_on_goto_level_select()

func _on_goto_level_select() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_goto_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func player_died(reason: String) -> void:
	if not is_level_active or get_tree().paused:
		return
	get_tree().paused = true
	if AudioManager:
		AudioManager.play_game_over()
	game_over_popup.show_game_over(reason)

func level_completed() -> void:
	if not is_level_active or get_tree().paused:
		return
	get_tree().paused = true
	if AudioManager:
		AudioManager.play_win()
	Global.unlock_next_level()
	game_over_popup.show_win(Global.current_level_index)
