extends CharacterBody3D
var hp_value:=5
signal hp
var SPEED =14
const JUMP_VELOCITY = 6
var can_be_hurt := true
enum state{
	WALK,ATTACK_HEAD,ATTACK_KICK,JUMP,DEATH,HEAD_LOW
}
var current_state
var playstats
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animal_armature: Node3D = $AnimalArmature
@onready var hurt_area: Area3D = $HurtArea
@onready var hurt_cool_timer: Timer = $HurtCoolTimer


func _process(delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	if is_on_floor() and current_state==state.WALK:
		$WalkParticiple.emitting=true
		
	
	if not is_on_floor():
		velocity += get_gravity() * delta*1.3
		$WalkParticiple.emitting=false
	
	#if($AudioStreamPlayer3D/Timer.time_left<=0 and is_on_floor()):
		#$AudioStreamPlayer3D.pitch_scale=randf_range(0.8,1.2)
		#$AudioStreamPlayer3D.play()
		#$AudioStreamPlayer3D/Timer.start(1.5)
	
	#contolli sono se vivo
	if current_state != state.DEATH:
		
		#salta Spazio
		if Input.is_action_pressed("ui_accept") and is_on_floor() and current_state == state.WALK:
			velocity.y = JUMP_VELOCITY
			
			animation_player.play("Gallop_Jump",-1,1.2)
			current_state = state.JUMP
		#attaca con testa	W oppuere tasto sinistro 
		elif Input.is_action_pressed("attack"):
			animation_player.play("Attack_Headbutt")
			current_state = state.ATTACK_HEAD
			_attackHead()
		#attaca con calcio	E oppuere tasto destro
		elif Input.is_action_pressed("kick") and is_on_floor() :
			animation_player.play("Attack_Kick")
			current_state = state.ATTACK_KICK
			_attackKick()
		#abbassarsi S oppure shift
		elif Input.is_action_pressed("shift") and is_on_floor() and current_state == state.WALK:
			animation_player.play("Idle_Headlow", -1, 5)
			animal_armature.scale *= Vector3(1, 0.6, 1)
			collision_shape_3d.scale *= Vector3(1, 0.6, 1)
			collision_shape_3d.position.y = 1.15
			current_state = state.HEAD_LOW
			SPEED = 12

	# A sinistra D destra
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_cancel")
	var direction := (transform.basis * Vector3(input_dir.x, 0, -1 )).normalized()

	if direction and current_state != state.DEATH:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	#inizzializazione
func _ready() -> void:
	playstats=self.get_parent_node_3d().get_node("PlayerStarts")
	current_state=state.WALK
	animation_player.play("Gallop")
	add_to_group("player")	
	hp.connect(get_parent_node_3d()._update_hp)
	#$AudioStreamPlayer3D.play()
	

#quando termina l'animazione cambia stato
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
		over.updateScore(get_parent_node_3d().get_node("PlayerStarts").points)
		over.visible = true
	else:
		current_state = state.WALK
		animation_player.play("Gallop")
# controllo HurtArea
func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body is Mob:
		if(!body.death):
			hp_value-=1;
			hp.emit(1)
			can_be_hurt = false
			hurt_cool_timer.start()
			_blood()
			
	if body is Trap:
		hp_value-=1;
		hp.emit(1)
		can_be_hurt = false
		hurt_cool_timer.start()
		_blood()
	if body is Spider:
		hp_value-=2;
		hp.emit(2)
		can_be_hurt = false
		hurt_cool_timer.start()
		_blood()		
	if(hp_value<=0):
			animation_player.play("Death")
			current_state=state.DEATH
			SPEED=1
	pass # Replace with function body.
#blink per simulare sangue
func _blood()-> void:
	var red_mat = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.7, 0.1, 0.08)
	$AnimalArmature/Skeleton3D/Stag.material_override=red_mat
	await get_tree().create_timer(0.2).timeout
	$AnimalArmature/Skeleton3D/Stag.material_override=null

# tempo di attesa per poter essere attacato di nuovo dai mob
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
	pass # Replace with function body.

#quando click attack genera un area di controllo per attack head e kick
func _attackHead()->void:
	var attack_area=preload("res://attack_head.tscn")
	var area=attack_area.instantiate()
	add_child(area)
	area.update_point.connect(playstats.add_points)
	pass
func _attackKick()->void:
	var attack_area=preload("res://attack_kick.tscn")
	add_child(attack_area.instantiate())
	pass	
