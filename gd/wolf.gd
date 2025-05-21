class_name Mob
extends CharacterBody3D


var SPEED = 8
const JUMP_VELOCITY = 4.5
var death:=false
@onready var player: CharacterBody3D = $"../../Player"

@onready var animation_player: AnimationPlayer = $"Root Scene/AnimationPlayer"
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _physics_process(delta: float) -> void:
	#se esiste il giocatore lupo corre verso giocatore e tende di attacarlo
	if is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		if(!death):
			var target_pos = player.global_position
			target_pos.y = global_position.y
			look_at(target_pos)

		
			if global_position.distance_to(player.global_position) < 2.0:
				animation_player.play("AnimalArmature|Attack")
			else:
				animation_player.play("AnimalArmature|Gallop")
	
	
	move_and_slide()
func _ready() -> void:
	animation_player.play("AnimalArmature|Gallop")

#lupo muore	
func die() -> void:
	collision_shape_3d.disabled=true
	visible=false
	SPEED=0
	death=true
	await get_tree().create_timer(0.2).timeout
	visible=true
	animation_player.play("Death")
	
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(death):
		call_deferred("queue_free")
	pass # Replace with function body.
