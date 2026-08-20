extends CharacterBody2D
class_name CharacterBase

@export var move_speed: float = 200.0
@export var follow_speed: float = 175.0
@export var is_active_character: bool = false
@export var partner_node: CharacterBase = null

var facing_left: bool = false
var step_sound_timer: float = 0.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("players")

func get_input_direction() -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1.0
	if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1.0
	return dir.normalized()

func _physics_process(delta: float) -> void:
	if is_active_character:
		var dir = get_input_direction()
		velocity = dir * move_speed
		
		# Step sounds
		if dir.length() > 0.1:
			step_sound_timer += delta
			if step_sound_timer >= 0.35:
				step_sound_timer = 0.0
				_on_step()
		else:
			step_sound_timer = 0.3
	else:
		# Partner Follow logic
		if Global.is_follow_active and partner_node and is_instance_valid(partner_node):
			var dist = global_position.distance_to(partner_node.global_position)
			if dist > 80.0:
				var follow_dir = (partner_node.global_position - global_position).normalized()
				velocity = follow_dir * follow_speed
			else:
				velocity = Vector2.ZERO
		else:
			velocity = Vector2.ZERO
			
	move_and_slide()
	_update_animation()
	_check_door_collisions()

func _on_step() -> void:
	if AudioManager:
		AudioManager.play_step()

func _update_animation() -> void:
	if not anim_sprite:
		return
		
	if velocity.x < -10.0:
		facing_left = true
	elif velocity.x > 10.0:
		facing_left = false
		
	var is_moving = velocity.length() > 10.0
	if is_moving:
		if facing_left:
			if anim_sprite.sprite_frames.has_animation("run left"):
				anim_sprite.play("run left")
		else:
			if anim_sprite.sprite_frames.has_animation("run right"):
				anim_sprite.play("run right")
	else:
		if facing_left:
			if anim_sprite.sprite_frames.has_animation("idle left"):
				anim_sprite.play("idle left")
		else:
			if anim_sprite.sprite_frames.has_animation("idle right"):
				anim_sprite.play("idle right")

func _check_door_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var coll = get_slide_collision(i)
		var collider = coll.get_collider()
		if collider and collider is MazeDoor:
			collider.try_unlock(self)

func set_active(active: bool) -> void:
	is_active_character = active
	queue_redraw()
