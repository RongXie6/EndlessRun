extends Button

var start:PackedScene

func _enter_tree() -> void:
	start=load("res://World.tscn")
	
func _on_pressed() -> void:
	get_tree().change_scene_to_packed(start)
	pass # Replace with function body.
