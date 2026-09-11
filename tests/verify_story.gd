extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func frames() -> void:
	for i in range(5):
		await process_frame

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	var state = root.get_node("Global")
	state.enter_level(1)
	await frames()
	check(current_scene.scene_file_path == "res://scenes/story.tscn", "Level one must open the prologue")
	check(not state.story_is_epilogue, "Prologue must not show ending text")
	current_scene._continue()
	await frames()
	check(current_scene.scene_file_path == "res://scenes/game_scene.tscn", "Continue must enter gameplay")
	current_scene.start_level(5)
	await frames()
	current_scene.level_completed()
	check(paused, "Completion pauses gameplay")
	check(current_scene.game_over_popup.next_level_btn.visible, "Final win must offer the ending")
	current_scene.game_over_popup.next_level_btn.pressed.emit()
	await frames()
	check(not paused, "Ending must clear pause")
	check(state.story_is_epilogue and current_scene.scene_file_path == "res://scenes/story.tscn", "Final win must open epilogue")
	current_scene._continue()
	await frames()
	check(current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Ending must return to menu")
	state.unlocked_level = 1
	current_scene._on_play()
	await frames()
	check(not state.story_is_epilogue, "Replaying must reset ending state")
	state.enter_level(2)
	await frames()
	check(current_scene.scene_file_path == "res://scenes/game_scene.tscn", "Later levels must skip prologue")
	check(state.current_level_index == 2, "Requested level must be preserved")
	print("Story flow: %d failures" % failures)
	quit(1 if failures else 0)
