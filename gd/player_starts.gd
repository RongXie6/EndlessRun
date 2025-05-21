extends Node

signal updated(points: int,km:int)
signal hp(value:int)
var points: int = 0
var distance:int =0;
var level:=1
func _ready() -> void:
	pass
#aggionamenti punteggi e distanze	

func add_points(p: int) -> void:
	points += p
	updated.emit(points,distance)
	pass
	
func add_distance() -> void:
	distance += 1
	updated.emit(points,distance)
	pass

func _update_hp(value:int)-> void:
	hp.emit(value)		
