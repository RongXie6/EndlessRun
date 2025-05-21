extends Control

@onready var label1: Label = $Label
@onready var player_starts: Node = $"../PlayerStarts"
@onready var label2: Label = $Label2
@onready var label3: Label = $Label3

var hp=5
var hp_max=5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_starts.updated.connect(_update_score)
	player_starts.hp.connect(_update_hp)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _update_score(new_score: int,new_distance: int) -> void:
	label1.text = str(new_score)
	label2.text = str(new_distance)+"km"
	
func _update_hp(value:int)-> void:
	label3.text=""
	hp-=value
	for i in range(hp):
		label3.text=" "+"❤️"+label3.text
		
		
	
