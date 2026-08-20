extends Node

# Procedural Audio Synthesizer for Engine-Craft
# Generates retro 8-bit / 16-bit sound effects directly via GDScript AudioStreamWAV

var sample_rate: int = 22050
var is_deaf_mode: bool = false # When deaf character is active, non-visual cues or audio can be filtered/muted

var _players: Array[AudioStreamPlayer] = []
var _max_players: int = 8
var _current_player_idx: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(_max_players):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)

func _get_player() -> AudioStreamPlayer:
	var p = _players[_current_player_idx]
	_current_player_idx = (_current_player_idx + 1) % _max_players
	return p

func _create_wav(data: PackedByteArray, loop: bool = false) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = data.size()
	return wav

# --- Sound Generators ---

func play_sonar_ping(high_pitch: bool = false) -> void:
	if is_deaf_mode:
		return
	var duration: float = 0.35
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	var base_freq: float = 900.0 if high_pitch else 600.0
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = base_freq + progress * 400.0
		var envelope: float = exp(-progress * 7.0)
		var val: float = sin(TAU * freq * t) * envelope
		# Add harmonic
		val += 0.3 * sin(TAU * (freq * 2.0) * t) * envelope
		var byte_val: int = clampi(int((val * 0.7 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
	
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -4.0
	player.play()

func play_step() -> void:
	if is_deaf_mode:
		return
	var duration: float = 0.08
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var progress: float = float(i) / num_samples
		var noise: float = (randf() * 2.0 - 1.0) * exp(-progress * 15.0)
		var byte_val: int = clampi(int((noise * 0.4 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -12.0
	player.play()

func play_switch() -> void:
	var duration: float = 0.25
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = 300.0 + progress * 800.0
		var envelope: float = sin(progress * PI)
		var val: float = sin(TAU * freq * t) * envelope
		var byte_val: int = clampi(int((val * 0.6 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -2.0
	player.play()

func play_pickup() -> void:
	var duration: float = 0.4
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = 523.25 # C5
		if progress > 0.66:
			freq = 783.99 # G5
		elif progress > 0.33:
			freq = 659.25 # E5
			
		var envelope: float = 1.0 - (fmod(progress * 3.0, 1.0) * 0.6)
		envelope *= (1.0 - progress)
		var val: float = (1.0 if sin(TAU * freq * t) > 0 else -1.0) * 0.3 * envelope
		val += sin(TAU * freq * t) * 0.5 * envelope
		var byte_val: int = clampi(int((val * 0.8 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -4.0
	player.play()

func play_door_open() -> void:
	var duration: float = 0.5
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = 180.0 - progress * 80.0
		var envelope: float = 1.0 - progress
		var val: float = sin(TAU * freq * t) * envelope
		val += (randf() * 2.0 - 1.0) * 0.2 * envelope
		var byte_val: int = clampi(int((val * 0.7 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -3.0
	player.play()

func play_monster_heartbeat() -> void:
	if is_deaf_mode:
		return
	var duration: float = 0.3
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = 55.0 - progress * 20.0
		var envelope: float = sin(progress * PI)
		var val: float = sin(TAU * freq * t) * envelope
		var byte_val: int = clampi(int((val * 0.8 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -2.0
	player.play()

func play_monster_alert() -> void:
	var duration: float = 0.6
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = 240.0 + sin(t * 40.0) * 80.0
		var envelope: float = exp(-progress * 3.0)
		var val: float = (1.0 if sin(TAU * freq * t) > 0 else -1.0) * 0.5 * envelope
		val += (randf() * 2.0 - 1.0) * 0.3 * envelope
		var byte_val: int = clampi(int((val * 0.7 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -1.0
	player.play()

func play_laser_buzz() -> void:
	var duration: float = 0.25
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = 120.0
		var val: float = (1.0 if sin(TAU * freq * t) > 0 else -1.0) * 0.5 * (1.0 - progress)
		var byte_val: int = clampi(int((val * 0.6 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -6.0
	player.play()

func play_win() -> void:
	var duration: float = 1.0
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	var notes = [523.25, 659.25, 783.99, 1046.50] # C5, E5, G5, C6
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var note_idx = clampi(int(progress * 4.0), 0, 3)
		var freq: float = notes[note_idx]
		var sub_progress: float = fmod(progress * 4.0, 1.0)
		var envelope: float = 1.0 - sub_progress * 0.8
		var val: float = sin(TAU * freq * t) * envelope * 0.6
		val += sin(TAU * (freq * 2.0) * t) * envelope * 0.3
		var byte_val: int = clampi(int((val * 0.8 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -2.0
	player.play()

func play_game_over() -> void:
	var duration: float = 0.8
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = 350.0 - progress * 200.0
		var envelope: float = 1.0 - progress
		var val: float = sin(TAU * freq * t) * envelope * 0.6
		val += (randf() * 2.0 - 1.0) * 0.2 * envelope
		var byte_val: int = clampi(int((val * 0.8 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -1.0
	player.play()

func play_plate_click() -> void:
	var duration: float = 0.1
	var num_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / num_samples
		var freq: float = 400.0 - progress * 200.0
		var val: float = sin(TAU * freq * t) * (1.0 - progress) * 0.5
		var byte_val: int = clampi(int((val * 0.6 + 1.0) * 127.5), 0, 255)
		bytes[i] = byte_val
		
	var player = _get_player()
	player.stream = _create_wav(bytes)
	player.volume_db = -4.0
	player.play()
