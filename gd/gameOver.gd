class_name gameOver
extends Control
var score:int
var label_node
func _ready():
	label_node = $Score
	
func updateScore(value:int)-> void:
	score=value
	label_node.text=str(score)
