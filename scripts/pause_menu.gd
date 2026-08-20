extends CanvasLayer
class_name PauseMenu

signal resume_requested
signal restart_requested
signal level_select_requested
signal main_menu_requested

@onready var resume_btn: Button = $CenterContainer/Panel/VBox/ResumeBtn
@onready var restart_btn: Button = $CenterContainer/Panel/VBox/RestartBtn
@onready var level_select_btn: Button = $CenterContainer/Panel/VBox/LevelSelectBtn
@onready var main_menu_btn: Button = $CenterContainer/Panel/VBox/MainMenuBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.pressed.connect(func(): resume_requested.emit())
	restart_btn.pressed.connect(func(): restart_requested.emit())
	level_select_btn.pressed.connect(func(): level_select_requested.emit())
	main_menu_btn.pressed.connect(func(): main_menu_requested.emit())
