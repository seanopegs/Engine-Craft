extends CanvasLayer
class_name GameOverPopup

signal next_level_requested
signal retry_requested
signal level_select_requested
signal main_menu_requested

@onready var title_label: Label = $CenterContainer/Panel/VBox/Title
@onready var message_label: Label = $CenterContainer/Panel/VBox/Message
@onready var next_level_btn: Button = $CenterContainer/Panel/VBox/NextLevelBtn
@onready var retry_btn: Button = $CenterContainer/Panel/VBox/RetryBtn
@onready var level_select_btn: Button = $CenterContainer/Panel/VBox/LevelSelectBtn
@onready var main_menu_btn: Button = $CenterContainer/Panel/VBox/MainMenuBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	next_level_btn.pressed.connect(func(): next_level_requested.emit())
	retry_btn.pressed.connect(func(): retry_requested.emit())
	level_select_btn.pressed.connect(func(): level_select_requested.emit())
	main_menu_btn.pressed.connect(func(): main_menu_requested.emit())

func show_win(level_idx: int) -> void:
	title_label.text = "★ LEVEL SELESAI! ★"
	title_label.modulate = Color(0.2, 1.0, 0.4)
	message_label.text = "Selamat! Anda berhasil menyelesaikan Level %d!" % level_idx
	if level_idx < Global.max_levels:
		next_level_btn.visible = true
		next_level_btn.text = "Lanjut Level %d ->" % (level_idx + 1)
	else:
		next_level_btn.visible = false
		message_label.text = "Luar Biasa! Semua 5 Level telah berhasil Anda taklukkan!"
	visible = true

func show_game_over(reason: String) -> void:
	title_label.text = "GAME OVER"
	title_label.modulate = Color(1.0, 0.25, 0.25)
	message_label.text = reason
	next_level_btn.visible = false
	visible = true
