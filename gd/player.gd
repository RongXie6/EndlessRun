extends CharacterBody3D

var hp_value := 5
signal hp

var SPEED = 14
const JUMP_VELOCITY = 6
var can_be_hurt := true

enum state {
	WALK, ATTACK_HEAD, ATTACK_KICK, JUMP, DEATH, HEAD_LOW
}
var current_state
var playstats


var TRACKS := [-4.0, 0.0, 4.0]
var track_index := 1

var current_x := 0.0
var target_x := 0.0
var lane_change_speed := 10.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animal_armature: Node3D = $AnimalArmature
@onready var hurt_area: Area3D = $HurtArea
@onready var hurt_cool_timer: Timer = $HurtCoolTimer

func _ready() -> void:
	playstats = get_parent_node_3d().get_node("PlayerStarts")
	current_state = state.WALK
	animation_player.play("Gallop")
	add_to_group("player")
	hp.connect(get_parent_node_3d()._update_hp)
	current_x = TRACKS[track_index]
	target_x = current_x

func _physics_process(delta: float) -> void:
	if is_on_floor() and current_state == state.WALK:
		$WalkParticiple.emitting = true
	else:
		$WalkParticiple.emitting = false
		
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.3
		
	if current_state != state.DEATH:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor() and current_state == state.WALK :
			velocity.y = JUMP_VELOCITY
			animation_player.play("Gallop_Jump", -1, 1.3)
			current_state = state.JUMP
		elif Input.is_action_pressed("attack"):
			animation_player.play("Attack_Headbutt")
			current_state = state.ATTACK_HEAD
			_attackHead()
		elif Input.is_action_pressed("kick") and is_on_floor():
			animation_player.play("Attack_Kick")
			current_state = state.ATTACK_KICK
			_attackKick()
		elif Input.is_action_pressed("shift") and is_on_floor() and current_state == state.WALK:
			animation_player.play("Idle_Headlow", -1, 5)
			animal_armature.scale *= Vector3(1, 0.6, 1)
			collision_shape_3d.scale *= Vector3(1, 0.6, 1)
			collision_shape_3d.position.y = 1.15
			current_state = state.HEAD_LOW
			SPEED = 12

		if Input.is_action_just_pressed("ui_left"):
			await get_tree().create_timer(0.01).timeout
			track_index = max(track_index - 1, 0)
			target_x = TRACKS[track_index]
		elif Input.is_action_just_pressed("ui_right"):
			await get_tree().create_timer(0.01).timeout
			track_index = min(track_index + 1, TRACKS.size() - 1)
			target_x = TRACKS[track_index]

	current_x = lerp(current_x, target_x, delta * lane_change_speed)
	var pos = global_transform.origin
	pos.x = current_x
	global_transform.origin = pos

	velocity.z = -SPEED
	velocity.x = 0
	move_and_slide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if current_state in [state.ATTACK_HEAD, state.ATTACK_KICK, state.HEAD_LOW]:
		animal_armature.scale = Vector3(100, 100, 100)
		collision_shape_3d.scale = Vector3(1, 1, 1)
		collision_shape_3d.position.y = 2.25
		SPEED = 14

	if current_state == state.DEATH:
		call_deferred("queue_free")
		get_parent_node_3d().clear()
		var over: gameOver = get_parent_node_3d().get_node("GameOver")
		over.updateScore(playstats.points)
		over.visible = true
	else:
		current_state = state.WALK
		animation_player.play("Gallop")

func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body is Mob and not body.death:
		_take_damage(1)
	elif body is Trap:
		_take_damage(1)
	elif body is Spider:
		_take_damage(2)

func _take_damage(amount: int) -> void:
	if not can_be_hurt:
		return
	hp_value -= amount
	hp.emit(amount)
	can_be_hurt = false
	hurt_cool_timer.start()
	_blood()
	if hp_value <= 0:
		SPEED = 0
		animation_player.play("Death")
		current_state = state.DEATH
		

func _on_hurt_cool_timer_timeout() -> void:
	var has_enemy := false
	for body in hurt_area.get_overlapping_bodies():
		if body is Mob and not body.death:
			hp_value -= 1
			hp.emit(1)
			_blood()
			if hp_value <= 0:
				animation_player.play("Death")
				current_state = state.DEATH
				SPEED = 1
				return
			has_enemy = true
			break
	if has_enemy:
		hurt_cool_timer.start()
	else:
		can_be_hurt = true

func _blood() -> void:
	var red_mat = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.7, 0.1, 0.08)
	$AnimalArmature/Skeleton3D/Stag.material_override = red_mat
	await get_tree().create_timer(0.2).timeout
	$AnimalArmature/Skeleton3D/Stag.material_override = null

func _attackHead() -> void:
	var attack_area = preload("res://attack_head.tscn").instantiate()
	add_child(attack_area)
	attack_area.update_point.connect(playstats.add_points)

func _attackKick() -> void:
	var attack_area = preload("res://attack_kick.tscn").instantiate()
	add_child(attack_area)
