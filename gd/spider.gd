class_name Spider
extends CharacterBody3D
@onready var animation_player: AnimationPlayer = $"Root Scene/AnimationPlayer"
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
var SPEED = 9
const JUMP_VELOCITY = 4.5
@onready var player: CharacterBody3D = $"../../Player"
var death:=false
var isAttack:=false
func _physics_process(delta: float) -> void:
	#spider vienne generato in base al livello dello gioco
	#verra generato in modo indiretto,attaca il giocatore solo una volta e scompare
	if is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		if(!death):
			var target_pos = player.global_position
			target_pos.y = global_position.y
			look_at(target_pos)
			
			if global_position.distance_to(player.global_position) < 2.0:
				$"Root Scene/AnimationPlayer".play("SpiderArmature|Spider_Attack")
				isAttack=true
			elif not isAttack:
				$"Root Scene/AnimationPlayer".play("SpiderArmature|Spider_Walk")

	move_and_slide()

func _ready() -> void:
	$"Root Scene/AnimationPlayer".play("SpiderArmature|Spider_Walk")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(isAttack):
		call_deferred("queue_free")
	pass # Replace with function body.

func die() -> void:
	collision_shape_3d.disabled=true
	visible=false
	SPEED=0
	death=true
	await get_tree().create_timer(0.2).timeout
	visible=true
	animation_player.play("SpiderArmature|Spider_Death")
