class_name FakeChest
extends RigidBody3D
@onready var player: CharacterBody3D = $"../../Player"
var attack:=false
# Called when the node enters the scene tree for the first time.
#in base al livello del gioco nel livello basso se il chest vienne aperto genera spider altrimenti quando il giocatore avvicina genera spider e tende di attacare giocatore
func _ready() -> void:
	var playstarts=self.get_parent_node_3d().get_parent_node_3d().get_node("PlayerStarts")
	if(playstarts.level>=4):
		attack=true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(player) and attack:
		if global_position.distance_to(player.global_position) < 10.0:
			_mob()
	pass


func _mob() -> void:
	var position=self.position
	var parent:=self.get_parent_node_3d()
	parent.remove_child(self)
	var spider=preload("res://Spider.tscn")
	var s=spider.instantiate()
	s.position=position
	parent.add_child(s)
	pass # Replace with function body.
