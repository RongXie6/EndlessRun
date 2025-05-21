extends Area3D
signal update_point
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.8).timeout
	call_deferred("queue_free")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	#uccidere i nemici
	if body is Mob or body is Spider:
		body.die()
		#aprire chest se sono veri cambia nodo con gold altrimenti genera il mob spider
	if body is Chest:
		var position=body.position
		var parent:=body.get_parent_node_3d()
		parent.remove_child(body)
		var chestGold=preload("res://ChestGold.tscn")
		var c=chestGold.instantiate()
		c.position=position
		parent.add_child(c) # Replace with function body.a
		update_point.emit(50)
	elif body is FakeChest:
		var position=body.position
		var parent:=body.get_parent_node_3d()
		parent.remove_child(body)
		var spider=preload("res://Spider.tscn")
		var s=spider.instantiate()
		s.position=position
		parent.add_child(s) # Replace with function body.a	
	pass # Replace with function body.
