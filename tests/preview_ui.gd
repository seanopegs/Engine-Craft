extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func shot(name: String) -> void:
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/" + name + ".png")

func run() -> void:
	for scene in ["main_menu", "level_select", "how_to_play", "game_scene"]:
		var view = load("res://scenes/" + scene + ".tscn").instantiate()
		root.add_child(view)
		await shot(scene)
		if scene == "main_menu":
			var settings = load("res://scripts/settings_menu.gd").new()
			view.add_child(settings)
			await shot("settings")
			settings.queue_free()
			await process_frame
		if scene == "game_scene":
			view._toggle_pause()
			await shot("pause")
			view._on_resume()
			view.game_over_popup.show_win(1)
			await shot("win")
		view.queue_free()
		await process_frame
	quit()
