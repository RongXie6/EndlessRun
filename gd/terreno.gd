extends Node3D

#Variabili esportate e preload
@export
var meshes:Array[Mesh]
var ostacoli:Array[PackedScene]=[preload("res://Wood.tscn"),preload("res://Fence.tscn")]
var mob:PackedScene=preload("res://Wolf.tscn")
var bonusScene:PackedScene=preload("res://Coin.tscn")
var silverCoin:PackedScene=preload("res://silverCoin.tscn")
var trap:PackedScene=preload("res://Trap.tscn")
var playstats
@onready var timer: Timer = $Timer
signal reached
var chests:Array[PackedScene]=[preload("res://Chest.tscn"),preload("res://FakeChest.tscn")]
# Called when the node enters the scene tree for the first time.

#_ready() prende le statistiche del giocatore (playstats).
#Se il livello è 2 o più e ci sono pochi ostacoli, aggiunge una trappola.
#Se il livello è almeno 3, genera un forziere.
#Poi genera il terreno, gli ostacoli, le monete e i nemici
func _ready() -> void:
	playstats=self.get_parent_node_3d().get_node("PlayerStarts")
	if(playstats.level>=2 and ostacoli.size()<3):
		_generateTrap()	
		pass
	if(playstats.level>=3):
		_generateChest()
			
	_generateMesh()
	_generateOstatoli()
	_generateCoin()
	_generateMob()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.



func _process(delta: float) -> void:
	pass
#Generazione dei nemici
func _generateMob() -> void:
	if randf()<0.1+playstats.level*0.1:
		var m=mob.instantiate()
		m.position = Vector3(randf_range(-4, 4), 0.5, randf_range(-8, -12))
		add_child(m)
		
#Generazione delle monete 		
func _generateCoin() -> void:
	var coin:SilverCoin
	var dx=randf_range(-4,4)
	var dz=randf_range(-10,10)
	var index=1;
	for i in range(1,8):	
		if randf()<0.5:
			coin=silverCoin.instantiate()
			coin.position=Vector3(dx,0.8,dz*-index*0.3)
			coin.collected.connect(get_parent_node_3d()._add_points)
			index+=1	
			add_child(coin)	
	pass
#Generazione degli ostacoli	
func _generateOstatoli() -> void:
	var ostacolo
	var new_position:Vector3
	var ox=	randf_range(-4,4)
	var oz=randf_range(-7,7)
	new_position=Vector3(ox,0.4,oz)
	
	if randf()<0.5:
		ostacolo=ostacoli[0].instantiate()
	else:
		ostacolo=ostacoli[1].instantiate()
	ostacolo.position=new_position		
	add_child(ostacolo)
	ostacolo.add_to_group("ostacoli")
	if ostacolo is Fence:
		_generateCoin_through(new_position)
	elif ostacolo is Wood:
		_genarateCoin_over(new_position)
	#generaTrap
	#controllo per evitare che gli ostacoli sono generati insieme o sovrapposti				
	if(playstats.level>=2):
		for i in range((1 + 0.25 * playstats.level)):
			var max:=0
			var created:=false;
			while !created and max<50:
				max+=1
				created=true;
				ox=	randf_range(-4,4)
				oz=randf_range(-8,8)
				new_position=Vector3(ox,0.4,oz)
				for o in get_children():
					if o.is_in_group("ostacoli"):
						if o.position.distance_to(new_position) < 6:
							created = false
							break
					
			if created:			
				ostacolo=ostacoli[2].instantiate()			
				ostacolo.position=new_position		
				add_child(ostacolo)
				ostacolo.add_to_group("ostacoli")		
	pass
#Aggiunta trappola	
func _generateTrap() ->void:
	
	ostacoli.push_back(trap)		
#Generazione del terreno		
func _generateMesh() -> void:
	for i in 100:
		var mi: MeshInstance3D = MeshInstance3D.new()
		mi.mesh = meshes[randi_range(0, meshes.size() - 1)]
		mi.position.z=randi_range(-10,10)

		if randf() < 0.5:
			mi.position.x = randf_range(-42, -6)  
		else:
			mi.position.x = randf_range(6, 42) 
		
		mi.position.z = randf_range(-10, 10)
		mi.scale = Vector3(randf_range(1, 2), randf_range(1, 2), randf_range(1, 2))
		#mi.position.y = mi.get_aabb().size.y / 2 
		add_child(mi)
	pass
#generazione chest 50% vera 50% falsa	
func _generateChest()-> void:
	if randf()<0.5:
		var x:=0
		var z:= randf_range(-8, -12)
		if randf() < 0.5:
			x = randf_range(-8, -6)  
		else:
			x = randf_range(6, 8)
		var chest	
		if randf() < 0.5:
			chest=chests[0].instantiate()
		else:
		
			chest=chests[1].instantiate()	
		chest.position=Vector3(x,0.5,z)
		add_child(chest)
#aggiornamenti distance e livelli			 		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		reached.emit()
		if(playstats.distance>=playstats.level*10):
			playstats.level+=1
	pass	 # Replace with function body.

#se runterrain esce dalla camera dopo qualche secondo viene eliminata
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	timer.start()
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	call_deferred("queue_free")
	#call_deferred("queue_free")
	pass # Replace with function body.


func _genarateCoin_over(position: Vector3) -> void:
	
	var coin_count := 5  
	var gravity := 9.8
	var t_total := 1
	var jump_range := 10 * t_total
	var arc_height := 1.84

	var base_x := position.x
	var base_y := position.y + 0.5
	var base_z := position.z + jump_range / 2

	for i in range(coin_count):
		
		var t := float(i) / float(coin_count - 1)
		var z := base_z - jump_range * t
		var x := base_x
		var y := -4.0 * arc_height * pow(t - 0.5, 2) + arc_height + base_y

		var coin := bonusScene.instantiate()
		coin.position = Vector3(x, y, z)
		coin.collected.connect(get_parent_node_3d()._add_points)
		add_child(coin)

#
func _generateCoin_through(position: Vector3) -> void:
	var coin_count := 3
	var spacing := 0.8
	var base_x := position.x
	var base_z := position.z

	for i in range(coin_count):
		var x := base_x
		var y := position.y + 1.0
		var z := base_z - i * spacing
		
		var coin := bonusScene.instantiate()
		coin.position = Vector3(x, y, z)
		coin.collected.connect(get_parent_node_3d()._add_points)
		add_child(coin)
