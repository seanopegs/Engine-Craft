extends CanvasLayer
class_name GameHUD

@onready var char_name_label: Label = $TopBar/Panel/HBox/CharInfo/CharName
@onready var char_desc_label: Label = $TopBar/Panel/HBox/CharInfo/CharDesc
@onready var char_avatar_rect: ColorRect = $TopBar/Panel/HBox/AvatarBox/Avatar
@onready var cooldown_bar: ProgressBar = $TopBar/Panel/HBox/CooldownBox/CooldownBar
@onready var cooldown_label: Label = $TopBar/Panel/HBox/CooldownBox/CooldownLabel
@onready var follow_label: Label = $TopBar/Panel/HBox/FollowLabel
@onready var level_label: Label = $TopBar/Panel/HBox/LevelLabel

@onready var red_key_label: Label = $KeysBar/RedKeys/Count
@onready var sound_key_label: Label = $KeysBar/SoundKeys/Count
@onready var blue_key_label: Label = $KeysBar/BlueKeys/Count

@onready var darkness_overlay: ColorRect = $DarknessOverlay

var pulse_anim: float = 0.0

func _ready() -> void:
	update_keys_display()

func _process(delta: float) -> void:
	pulse_anim += delta * 4.0
	update_keys_display()

func update_hud(is_blind: bool, cooldown_remaining: float, max_cooldown: float, is_following: bool, current_lvl: int) -> void:
	level_label.text = "LEVEL %d" % current_lvl
	
	if is_blind:
		char_name_label.text = "BUTA (ECHO / SOUND)"
		char_name_label.modulate = Color(0.2, 0.9, 1.0)
		char_desc_label.text = "Bisa Dengar Sonar [SPACE/E] | Layar Gelap"
		char_avatar_rect.color = Color(0.1, 0.6, 0.9)
		darkness_overlay.visible = true
	else:
		char_name_label.text = "TULI (SIGHT / VISUAL)"
		char_name_label.modulate = Color(1.0, 0.85, 0.2)
		char_desc_label.text = "Bisa Lihat Laser & Warna | Tidak Ada Suara"
		char_avatar_rect.color = Color(0.9, 0.7, 0.1)
		darkness_overlay.visible = false
		
	if cooldown_remaining > 0.0:
		var ratio = 1.0 - (cooldown_remaining / max_cooldown)
		cooldown_bar.value = ratio * 100.0
		cooldown_label.text = "SWITCH: %.1fs" % cooldown_remaining
		cooldown_label.modulate = Color(1.0, 0.5, 0.5)
	else:
		cooldown_bar.value = 100.0
		cooldown_label.text = "SWITCH SIAP [TAB / Q]"
		cooldown_label.modulate = Color(0.4, 1.0, 0.4)
		
	follow_label.text = "[F] FOLLOW: " + ("ON" if is_following else "STAY")
	follow_label.modulate = Color(0.3, 1.0, 0.5) if is_following else Color(0.9, 0.9, 0.3)

func update_keys_display() -> void:
	if red_key_label:
		red_key_label.text = str(Global.keys_collected.get("red", 0))
	if sound_key_label:
		sound_key_label.text = str(Global.keys_collected.get("sound", 0))
	if blue_key_label:
		blue_key_label.text = str(Global.keys_collected.get("blue", 0))
