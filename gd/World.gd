class_name World
extends Node3D

var terreno:PackedScene=preload("res://Terreno.tscn")
var num_terrain:int=1
@onready var player: CharacterBody3D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generateChunck()
	pass # Replace with function body.

#generazione terenno 
func _generateChunck() -> void:
	
	for i in 5:
		var t=terreno.instantiate()
		t.position.z=-20*(i+num_terrain)
		if(i==1):
			t.reached.connect(_generateChunck)
		t.reached.connect(_add_Distance)
		add_child(t)
	num_terrain+=5
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func _add_points(point: int) -> void:
	$PlayerStarts.add_points(point)
	pass
func _add_Distance() -> void:
	$PlayerStarts.add_distance()
	pass
func _update_hp(value:int)->void:
		$PlayerStarts._update_hp(value)
#func _on_coin_body_entered(body: Node) -> void:

	#if body is CharacterBody3D:
	#	print(222)
	#	$PlayerStarts.add_points(5)
	#pass # Replace with function body.
#
func _process(delta: float) -> void:
	
		pass
func clear()->void:
	if(not is_instance_valid(player)):
		for i in get_children():
			if(i is not gameOver):
				i.call_deferred("queue_free")
